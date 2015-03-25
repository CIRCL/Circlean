#!/usr/bin/env python
# -*- coding: utf-8 -*-
import magic
import os
import shutil
import mimetypes
from twiggy import quickSetup, log
import shlex
import subprocess
import time


LIBREOFFICE = '/usr/bin/unoconv'
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


class File(object):

    def __init__(self, src_path, dst_path, main_type, sub_type):
        self.src_path = src_path
        self.dst_path = dst_path
        self.main_type = main_type
        self.sub_type = sub_type
        self.log_details = {'filepath': self.src_path, 'maintype': self.main_type,
                            'subtype': self.sub_type}
        self.expected_mimetype, self.expected_extensions = self.crosscheck_mime()
        self.is_recursive = False
        self.log_string = ''

    def add_log_details(self, key, value):
        self.log_details[key] = value

    def crosscheck_mime(self):
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
        if self.expected_extensions is None:
            return None
        path, actual_extension = os.path.splitext(self.src_path)
        return actual_extension in self.expected_extensions

    def verify_mime(self):
        if self.expected_mimetype is None:
            return None
        actual_mimetype = '{}/{}'.format(self.main_type, self.sub_type)
        return actual_mimetype == self.expected_mimetype

    def make_dangerous(self):
        self.log_details['dangerous'] = True
        path, filename = os.path.split(self.dst_path)
        self.dst_path = os.path.join(path, 'DANGEROUS_{}_DANGEROUS'.format(filename))

    def make_unknown(self):
        self.log_details['unknown'] = True
        path, filename = os.path.split(self.dst_path)
        self.dst_path = os.path.join(path, 'UNKNOWN_{}'.format(filename))

    def make_binary(self):
        self.log_details['binary'] = True
        path, filename = os.path.split(self.dst_path)
        self.dst_path = os.path.join(path, '{}.bin'.format(filename))


class KittenGroomer(object):

    def __init__(self, max_recursive=5):
        self.src_root_dir = os.path.join(os.sep, 'media', 'src')
        self.dst_root_dir = os.path.join(os.sep, 'media', 'dst')
        self.log_root_dir = os.path.join(self.dst_root_dir, 'logs')
        self.log_processing = os.path.join(self.log_root_dir, 'processing.log')

        self.recursive = 0
        self.max_recursive = max_recursive

        # quickSetup(file=self.log_processing)
        quickSetup()
        self.log_name = log.name('files')

        self.cur_file = None

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

    # ##### Helpers #####
    def _init_subtypes_application(self, subtypes_application):
        to_return = {}
        for list_subtypes, fct in subtypes_application:
            for st in list_subtypes:
                to_return[st] = fct
        return to_return

    def _safe_rmtree(self, directory):
        if os.path.exists(directory):
            shutil.rmtree(directory)

    def _safe_remove(self, filepath):
        if os.path.exists(filepath):
            os.remove(filepath)

    def _safe_mkdir(self, directory):
        if not os.path.exists(directory):
            os.makedirs(directory)

    def _safe_copy(self):
        ''' Create dir if needed '''
        try:
            dst_path, filename = os.path.split(self.cur_file.dst_path)
            self._safe_mkdir(dst_path)
            shutil.copy(self.cur_file.src_path, self.cur_file.dst_path)
            return True
        except Exception as e:
            # TODO: Logfile
            print(e)
            return False

    def _list_all_files(self, directory):
        for root, dirs, files in os.walk(directory):
            for filename in files:
                filepath = os.path.join(root, filename)
                mimetype = magic.from_file(filepath, mime=True)
                maintype, subtype = mimetype.split('/')
                yield filepath, maintype, subtype

    def _run_process(self, command_line):
        args = shlex.split(command_line)
        p = subprocess.Popen(args)
        while True:
            code = p.poll()
            if code is not None:
                break
            time.sleep(1)
        return True

    def _print_log(self):
        tmp_log = self.log_name.fields(**self.cur_file.log_details)
        if self.cur_file.log_details.get('dangerous'):
            tmp_log.warning(self.cur_file.log_string)
        elif self.cur_file.log_details.get('unknown') or self.cur_file.log_details.get('binary'):
            tmp_log.info(self.cur_file.log_string)
        else:
            tmp_log.debug(self.cur_file.log_string)

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
        self.cur_file.log_string += 'Example file'
        self.cur_file.make_dangerous()
        self._safe_copy()

    def message(self):
        self.cur_file.log_string += 'Message file'
        self.cur_file.make_dangerous()
        self._safe_copy()

    def model(self):
        self.cur_file.log_string += 'Model file'
        self.cur_file.make_dangerous()
        self._safe_copy()

    def multipart(self):
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
        for subtype, fct in self.subtypes_application.iteritems():
            if subtype in self.cur_file.sub_type:
                fct()
                self.cur_file.log_string += 'Application file'
                return
        self.cur_file.log_string += 'Unknown Application file'
        self._unknown_app()

    def _executables(self):
        self.cur_file.add_log_details('processing_type', 'executable')
        self.cur_file.make_dangerous()
        self._safe_copy()

    def _office_related(self):
        self.cur_file.add_log_details('processing_type', 'office')
        dst_path, filename = os.path.split(self.cur_file.dst_path)
        name, ext = os.path.splitext(filename)
        tmpdir = os.path.join(dst_path, 'temp')
        tmppath = os.path.join(tmpdir, name, '.pdf')
        self._safe_mkdir(tmpdir)
        lo_command = '{} --format pdf -eSelectPdfVersion=1 --output {} {}'.format(
            LIBREOFFICE, tmppath, self.cur_file.src_path)
        self._run_process(lo_command)
        pdf_command = '{} --dest-dir=/ {} {}'.format(PDF2HTMLEX, tmppath, self.cur_file.dst_path)
        self._run_process(pdf_command)
        self._safe_rmtree(tmpdir)

    def _pdf(self):
        self.cur_file.add_log_details('processing_type', 'pdf')
        # TODO: Convert to pdf/A
        pdf_command = '{} --dest-dir {} {}'.format(PDF2HTMLEX, self.cur_file.dst_path, self.cur_file.src_path)
        self._run_process(pdf_command)

    def _archive(self):
        self.cur_file.add_log_details('processing_type', 'archive')
        self.cur_file.is_recursive = True
        self.cur_file.log_string += 'Archive extracted, processing content.'
        self.recursive += 1
        tmpdir = self.cur_file.dst_path + '_temp'
        self._safe_mkdir(tmpdir)
        extract_command = '{} -p1 x {} -o{} -bd'.format(SEVENZ, self.cur_file.src_path, tmpdir)
        self._run_process(extract_command)
        self.processdir(self.cur_file.dst_path, tmpdir)
        self._safe_rmtree(tmpdir)
        self.recursive -= 1

    def _unknown_app(self):
        self.cur_file.make_unknown()
        self._safe_copy()

    def _binary_app(self):
        self.cur_file.make_binary()
        self._safe_copy()

    #######################

    # ##### Not converted, checking the mime type ######
    def audio(self):
        self.cur_file.log_string += 'Audio file'
        self._media_processing()

    def image(self):
        self.cur_file.log_string += 'Image file'
        self._media_processing()

    def video(self):
        self.cur_file.log_string += 'Video file'
        self._media_processing()

    def _media_processing(self):
        self.cur_log.fields(processing_type='media')
        if not self.cur_file.verify_mime() or not self.cur_file.verify_extension():
            # The extension is unknown or doesn't match the mime type, suspicious
            # TODO: write details in the logfile
            self.cur_file.make_dangerous()
        self._safe_copy()

    #######################

    def processdir(self, dst_dir=None, src_dir=None):
        if dst_dir is None:
            dst_dir = self.dst_root_dir
        if src_dir is None:
            src_dir = self.src_root_dir

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

        for srcpath, maintype, subtype in self._list_all_files(src_dir):
            self.log_name.info('Processing {} ({}/{})', srcpath.replace(src_dir + '/', ''),
                               maintype, subtype)
            self.cur_file = File(srcpath, srcpath.replace(src_dir, dst_dir),
                                 maintype, subtype)

            self.mime_processing_options.get(maintype, self.unknown)()
            if not self.cur_file.is_recursive:
                self._print_log()

if __name__ == '__main__':
    kg = KittenGroomer()
    kg.processdir('/home/raphael/gits/KittenGroomer/tests/content_img_vfat_norm_out',
                  '/home/raphael/gits/KittenGroomer/tests/content_img_vfat_norm')
