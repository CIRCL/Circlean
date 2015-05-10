#!/usr/bin/env python
# -*- coding: utf-8 -*-
import magic
import os
import mimetypes
import shlex
import subprocess
import time

from kittengroomer import FileBase, KittenGroomerBase, main

UNOCONV = '/usr/bin/unoconv'
LIBREOFFICE = '/usr/bin/libreoffice'
GS = '/usr/bin/gs'
PDF2HTMLEX = '/usr/bin/pdf2htmlEX'
SEVENZ = '/usr/bin/7z'


# Prepare application/<subtype>
mimes_office = ['msword', 'vnd.openxmlformats-officedocument.', 'vnd.ms-',
                'vnd.oasis.opendocument']
mimes_pdf = ['pdf']
mimes_xml = ['xml']
mimes_ms = ['x-dosexec']
mimes_compressed = ['zip', 'x-rar', 'x-bzip2', 'x-lzip', 'x-lzma', 'x-lzop',
                    'x-xz', 'x-compress', 'x-gzip', 'x-tar', 'compressed']
mimes_data = ['octet-stream']


class File(FileBase):

    def __init__(self, src_path, dst_path):
        ''' Init file object, set the mimetype '''
        super(File, self).__init__(src_path, dst_path)
        mimetype = magic.from_file(src_path, mime=True)
        self.main_type, self.sub_type = mimetype.split('/')
        self.log_details.update({'maintype': self.main_type, 'subtype': self.sub_type})
        self.expected_mimetype, self.expected_extensions = self.crosscheck_mime()
        self.is_recursive = False

    def crosscheck_mime(self):
        '''
            Set the expected mime and extension variables based on mime type.
        '''
        # /usr/share/mime has interesting stuff

        # guess_type uses the extension to get a mime type
        expected_mimetype, encoding = mimetypes.guess_type(self.src_path, strict=False)
        if expected_mimetype is not None:
            expected_extensions = mimetypes.guess_all_extensions(expected_mimetype,
                                                                 strict=False)
        else:
            # the extension is unknown...
            expected_extensions = None

        return expected_mimetype, expected_extensions

    def verify_extension(self):
        '''Check if the extension is the one we expect'''
        if self.expected_extensions is None:
            return None
        path, actual_extension = os.path.splitext(self.src_path)
        return actual_extension in self.expected_extensions

    def verify_mime(self):
        '''Check if the mime is the one we expect'''
        if self.expected_mimetype is None:
            return None
        actual_mimetype = '{}/{}'.format(self.main_type, self.sub_type)
        return actual_mimetype == self.expected_mimetype


class KittenGroomer(KittenGroomerBase):

    def __init__(self, root_src=None, root_dst=None, max_recursive=5):
        '''
            Initialize the basics of the conversion process
        '''
        if root_src is None:
            root_src = os.path.join(os.sep, 'media', 'src')
        if root_dst is None:
            root_dst = os.path.join(os.sep, 'media', 'dst')
        super(KittenGroomer, self).__init__(root_src, root_dst)

        self.recursive = 0
        self.max_recursive = max_recursive

        subtypes_apps = [
            (mimes_office, self._office_related),
            (mimes_pdf, self._pdf),
            (mimes_xml, self._office_related),
            (mimes_ms, self._executables),
            (mimes_compressed, self._archive),
            (mimes_data, self._binary_app),
        ]
        self.subtypes_application = self._init_subtypes_application(subtypes_apps)

        self.mime_processing_options = {
            'text': self.text,
            'audio': self.audio,
            'image': self.image,
            'video': self.video,
            'application': self.application,
            'example': self.example,
            'message': self.message,
            'model': self.model,
            'multipart': self.multipart,
            'inode': self.inode,
        }

        # Dirty trick to run libreoffice at least once and avoid unoconv to crash...
        self._run_process(LIBREOFFICE, 5)

    # ##### Helpers #####
    def _init_subtypes_application(self, subtypes_application):
        '''
            Create the Dict to pick the right function based on the sub mime type
        '''
        to_return = {}
        for list_subtypes, fct in subtypes_application:
            for st in list_subtypes:
                to_return[st] = fct
        return to_return

    def _print_log(self):
        '''
            Print the logs related to the current file being processed
        '''
        tmp_log = self.log_name.fields(**self.cur_file.log_details)
        if self.cur_file.log_details.get('dangerous'):
            tmp_log.warning(self.cur_file.log_string)
        elif self.cur_file.log_details.get('unknown') or self.cur_file.log_details.get('binary'):
            tmp_log.info(self.cur_file.log_string)
        else:
            tmp_log.debug(self.cur_file.log_string)

    def _run_process(self, command_line, timeout=0):
        '''Run subprocess, wait until it finishes'''
        if timeout != 0:
            deadline = time.time() + timeout
        else:
            deadline = None
        args = shlex.split(command_line)
        p = subprocess.Popen(args)
        while True:
            code = p.poll()
            if code is not None:
                break
            if deadline is not None and time.time() > deadline:
                p.kill()
                break
            time.sleep(1)
        return True

    #######################

    # ##### Discarded mime types, reason in the comments ######
    def inode(self):
        ''' Usually empty file. No reason (?) to copy it on the dest key'''
        self.cur_file.log_string += 'Inode file'

    def unknown(self):
        ''' This main type is unknown, that should not happen '''
        self.cur_file.log_string += 'Unknown file'

    # ##### Threated as malicious, no reason to have it on a USB key ######
    def example(self):
        '''Way to process example file'''
        self.cur_file.log_string += 'Example file'
        self.cur_file.make_dangerous()
        self._safe_copy()

    def message(self):
        '''Way to process message file'''
        self.cur_file.log_string += 'Message file'
        self.cur_file.make_dangerous()
        self._safe_copy()

    def model(self):
        '''Way to process model file'''
        self.cur_file.log_string += 'Model file'
        self.cur_file.make_dangerous()
        self._safe_copy()

    def multipart(self):
        '''Way to process multipart file'''
        self.cur_file.log_string += 'Multipart file'
        self.cur_file.make_dangerous()
        self._safe_copy()

    #######################

    # ##### Converted ######
    def text(self):
        ''' LibreOffice should be able to open all the files '''
        self.cur_file.log_string += 'Text file'
        self._office_related()

    def application(self):
        ''' Everything can be there, using the subtype to decide '''
        for subtype, fct in list(self.subtypes_application.items()):
            if subtype in self.cur_file.sub_type:
                fct()
                self.cur_file.log_string += 'Application file'
                return
        self.cur_file.log_string += 'Unknown Application file'
        self._unknown_app()

    def _executables(self):
        '''Way to process executable file'''
        self.cur_file.add_log_details('processing_type', 'executable')
        self.cur_file.make_dangerous()
        self._safe_copy()

    def _office_related(self):
        '''Way to process all the files LibreOffice can handle'''
        self.cur_file.add_log_details('processing_type', 'office')
        dst_dir, filename = os.path.split(self.cur_file.dst_path)
        tmpdir = os.path.join(dst_dir, 'temp')
        name, ext = os.path.splitext(filename)
        tmppath = os.path.join(tmpdir, name + '.pdf')
        self._safe_mkdir(tmpdir)
        lo_command = '{} --format pdf -eSelectPdfVersion=1 --output {} {}'.format(
            UNOCONV, tmppath, self.cur_file.src_path)
        self._run_process(lo_command)
        self._pdfa(tmppath)
        self._safe_rmtree(tmpdir)

    def _pdfa(self, tmpsrcpath):
        '''Way to process PDF/A file'''
        pdf_command = '{} --dest-dir / {} {}'.format(PDF2HTMLEX, tmpsrcpath,
                                                     self.cur_file.dst_path + '.html')
        self._run_process(pdf_command)

    def _pdf(self):
        '''Way to process PDF file'''
        self.cur_file.add_log_details('processing_type', 'pdf')
        dst_dir, filename = os.path.split(self.cur_file.dst_path)
        tmpdir = os.path.join(dst_dir, 'temp')
        tmppath = os.path.join(tmpdir, filename)
        self._safe_mkdir(tmpdir)
        gs_command = '{} -dPDFA -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile={} {}'.format(
            GS, tmppath, self.cur_file.src_path)
        self._run_process(gs_command)
        self._pdfa(tmppath)
        self._safe_rmtree(tmpdir)

    def _archive(self):
        '''Way to process Archive'''
        self.cur_file.add_log_details('processing_type', 'archive')
        self.cur_file.is_recursive = True
        self.cur_file.log_string += 'Archive extracted, processing content.'
        tmpdir = self.cur_file.dst_path + '_temp'
        self._safe_mkdir(tmpdir)
        extract_command = '{} -p1 x {} -o{} -bd'.format(SEVENZ, self.cur_file.src_path, tmpdir)
        self._run_process(extract_command)
        self.recursive += 1
        self.processdir(tmpdir, self.cur_file.dst_path)
        self.recursive -= 1
        self._safe_rmtree(tmpdir)

    def _unknown_app(self):
        '''Way to process an unknown file'''
        self.cur_file.make_unknown()
        self._safe_copy()

    def _binary_app(self):
        '''Way to process an unknown binary file'''
        self.cur_file.make_binary()
        self._safe_copy()

    #######################

    # ##### Not converted, checking the mime type ######
    def audio(self):
        '''Way to process an audio file'''
        self.cur_file.log_string += 'Audio file'
        self._media_processing()

    def image(self):
        '''Way to process an image'''
        self.cur_file.log_string += 'Image file'
        self._media_processing()

    def video(self):
        '''Way to process a video'''
        self.cur_file.log_string += 'Video file'
        self._media_processing()

    def _media_processing(self):
        '''Generic way to process all the media files'''
        self.cur_log.fields(processing_type='media')
        if not self.cur_file.verify_mime() or not self.cur_file.verify_extension():
            # The extension is unknown or doesn't match the mime type => suspicious
            # TODO: write details in the logfile
            self.cur_file.make_dangerous()
        self._safe_copy()

    #######################

    def processdir(self, src_dir=None, dst_dir=None):
        '''
            Main function doing the processing
        '''
        if src_dir is None:
            src_dir = self.src_root_dir
        if dst_dir is None:
            dst_dir = self.dst_root_dir

        if self.recursive > 0:
            self._print_log()

        if self.recursive >= self.max_recursive:
            self.cur_log.warning('ARCHIVE BOMB.')
            self.cur_log.warning('The content of the archive contains recursively other archives.')
            self.cur_log.warning('This is a bad sign so the archive is not extracted to the destination key.')
            self._safe_rmtree(src_dir)
            if src_dir.endswith('_temp'):
                archbomb_path = src_dir[:-len('_temp')]
                self._safe_remove(archbomb_path)

        for srcpath in self._list_all_files(src_dir):
            self.cur_file = File(srcpath, srcpath.replace(src_dir, dst_dir))

            self.log_name.info('Processing {} ({}/{})', srcpath.replace(src_dir + '/', ''),
                               self.cur_file.main_type, self.cur_file.sub_type)
            self.mime_processing_options.get(self.cur_file.main_type, self.unknown)()
            if not self.cur_file.is_recursive:
                self._print_log()

if __name__ == '__main__':
    main(KittenGroomer, 'Generic version of the KittenGroomer. Convert and rename files.')
