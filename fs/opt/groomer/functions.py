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


LIBREOFFICE = '/usr/bin/libreoffice'
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
mimes_unknown = ['octet-stream']


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
        self.log_name = None

        self.cur_src = None
        self.cur_dst = None
        self.cur_type = None
        self.cur_subtype = None

        subtypes_apps = [
            (mimes_office, self._office_related),
            (mimes_pdf, self._pdf),
            (mimes_xml, self._office_related),
            (mimes_ms, self.dangerous),
            (mimes_compressed, self.archive),
            (mimes_unknown, self.unknown),
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

    def _init_subtypes_application(self, subtypes_application):
        to_return = {}
        for list_subtypes, fct in subtypes_application:
            for st in list_subtypes:
                to_return[st] = fct
        return to_return

    # ##### Discarded mime types, reason in the comments ######
    def inode(self):
        ''' Usually empty file. No reason (?) to copy it on the dest key'''
        pass

    def unknown(self):
        ''' This main type is inknown, that should not happen '''
        pass

    #######################

    def check_mime(self):
        # /usr/share/mime has interesting stuff

        # guess_type uses the extension to get a mime type
        expected_mimetype, encoding = mimetypes.guess_type(self.cur_src, strict=False)
        if expected_mimetype is not None:
            expected_extensions = mimetypes.guess_all_extensions(expected_mimetype,
                                                                 strict=False)
        else:
            # the extension is unknown...
            expected_extensions = None

        actual_mimetype = '{}/{}'.format(self.cur_type, self.cur_subtype)
        path, actual_extension = os.path.splitext(self.cur_src)

        if expected_extensions is None and expected_mimetype is None:
            # Unknown ext/mime, that happens
            return (None, actual_mimetype, actual_extension)

        matching_mimetype = actual_mimetype == expected_mimetype
        matching_extension = actual_extension in expected_extensions

        details = {}
        if not matching_mimetype:
            details['mimes'] = expected_mimetype
        if not matching_extension:
            details['extensions'] = expected_extensions

        if len(details) == 0:
            # Everything is fine
            return (True, actual_mimetype, actual_extension)
        return (False, actual_mimetype, actual_extension, details)

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
            dst_path, filename = os.path.split(self.cur_dst)
            self._safe_mkdir(dst_path)
            shutil.copy(self.cur_src, self.cur_dst)
            return True
        except Exception as e:
            # TODO: Logfile
            print(e)
            return False

    def copy(self):
        return self._safe_copy()

    def dangerous(self):
        path, filename = os.path.split(self.cur_dst)
        self.cur_dst = os.path.join(path, 'DANGEROUS_{}_DANGEROUS'.format(filename))
        return self._safe_copy()

    def run_process(self, command_line):
        args = shlex.split(command_line)
        p = subprocess.Popen(args)
        while True:
            code = p.poll()
            if code is not None:
                break
            time.sleep(1)
        return True

    # ##### Converted ######
    def _office_related(self):
        dst_path, filename = os.path.split(self.cur_dst)
        tmpdir = os.path.join(dst_path, 'temp')
        self._safe_mkdir(tmpdir)
        # TODO; Convert to pdf/A
        lo_command = '{} --headless --convert-to pdf --outdir {} {}'.format(
            LIBREOFFICE, tmpdir, self.cur_src)
        self.run_process(lo_command)
        pdf_command = '{} --dest-dir=/ {}/*.pdf {}'.format(PDF2HTMLEX, tmpdir, self.cur_dst)
        self.run_process(pdf_command)
        self._safe_rmtree(tmpdir)

    def _pdf(self):
        # TODO: Convert to pdf/A
        pdf_command = '{} --dest-dir {} {}'.format(PDF2HTMLEX, self.cur_dst, self.cur_src)
        self.run_process(pdf_command)

    def archive(self):
        self.recursive += 1
        tmpdir = self.cur_dst + '_temp'
        self._safe_mkdir(tmpdir)
        extract_command = '{} -p1 x {} -o{} -bd'.format(SEVENZ, self.cur_src, tmpdir)
        self.run_process(extract_command)
        self.processdir(self.cur_dst, tmpdir)
        self._safe_rmtree(tmpdir)
        self.recursive -= 1

    def text(self):
        ''' LibreOffice should be able to open all the files '''
        return self._office_related()

    def application(self):
        ''' Everything can be there, using the subtype to decide '''
        return self.subtypes_application.get(self.cur_subtype, self.unknown)()

    #######################

    # ##### Not converted, checking the mime type ######
    def _media_processing(self):
        clean, mimetype, extension, details = self.check_mime()
        # TODO: write details in the logfile

        if clean:
            # Just copy, the extension matches the mime type
            return self.copy()
        else:
            # The extension is unknown or doesn't match the mime type, suspicious
            return self.dangerous()

    def audio(self):
        return self._media_processing()

    def image(self):
        return self._media_processing()

    def video(self):
        return self._media_processing()

    #######################

    # ##### Threated as malicious, no reason to have it on a USB key ######
    def example(self):
        return self.dangerous()

    def message(self):
        return self.dangerous()

    def model(self):
        return self.dangerous()

    def multipart(self):
        return self.dangerous()

    #######################

    def _list_all_files(self, directory):
        for root, dirs, files in os.walk(directory):
            for filename in files:
                filepath = os.path.join(root, filename)
                mimetype = magic.from_file(filepath, mime=True)
                maintype, subtype = mimetype.split('/')
                yield filepath, maintype, subtype

    def processdir(self, dst_dir=None, src_dir=None):
        if dst_dir is None:
            dst_dir = self.dst_root_dir
        if src_dir is None:
            src_dir = self.src_root_dir
        if self.recursive >= self.max_recursive:
            self._safe_rmtree(src_dir)
            if src_dir.endswith('_temp'):
                archbomb_path = src_dir[:-len('_temp')]
                self._safe_remove(archbomb_path)

        logname_files = log.name('files')
        for srcpath, maintype, subtype in self._list_all_files(src_dir):
            logname_files.info('Processing {} ({}/{})', srcpath, maintype, subtype)
            self.cur_src = srcpath
            self.cur_dst = srcpath.replace(src_dir, dst_dir)
            self.cur_type = maintype
            self.cur_subtype = subtype

            self.mime_processing_options.get(maintype, self.unknown)()


if __name__ == '__main__':
    kg = KittenGroomer()
    kg.processdir('dst', 'src')
