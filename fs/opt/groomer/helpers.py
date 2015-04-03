#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import shutil
from twiggy import quickSetup, log
import shlex
import subprocess
import time


class KittenGroomerError(Exception):
    def __init__(self, message):
        super(KittenGroomerError, self).__init__(message)
        self.message = message


class ImplementationRequired(KittenGroomerError):
    pass


class FileBase(object):

    def __init__(self, src_path, dst_path):
        self.src_path = src_path
        self.dst_path = dst_path
        self.log_details = {'filepath': self.src_path}
        self.log_string = ''

    def add_log_details(self, key, value):
        self.log_details[key] = value

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


class KittenGroomerBase(object):

    def __init__(self, root_src, root_dst):
        self.src_root_dir = root_src
        self.dst_root_dir = root_dst
        self.log_root_dir = os.path.join(self.dst_root_dir, 'logs')
        self.log_processing = os.path.join(self.log_root_dir, 'processing.log')

        # quickSetup(file=self.log_processing)
        quickSetup()
        self.log_name = log.name('files')

        self.cur_file = None

    # ##### Helpers #####
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
                yield filepath

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
        # Not implemented
        pass

    #######################

    def processdir(self, src_dir=None, dst_dir=None):
        raise ImplementationRequired('You have to implement the result processdir.')
