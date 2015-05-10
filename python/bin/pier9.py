#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os

from kittengroomer import FileBase, KittenGroomerBase, main


printers = ['.STL', '.obj']
cnc = ['.nc', '.tap', '.gcode', '.dxf', '.stl', '.obj', '.iges', '.igs',
       '.vrml', '.vrl', '.thing', '.step', '.stp', '.x3d']
shopbot = ['.ai', '.svg', '.dxf', '.dwg', '.eps']
omax = ['.ai', '.svg', '.dxf', '.dwg', '.eps', '.omx', '.obj']
epilog_laser = ['.ai', '.svg', '.dxf', '.dwg', '.eps']
metabeam = ['.dxf']
up = ['.upp', '.up3', '.stl', '.obj']


class FilePier9(FileBase):

    def __init__(self, src_path, dst_path):
        ''' Init file object, set the extension '''
        super(FilePier9, self).__init__(src_path, dst_path)
        a, self.extension = os.path.splitext(self.src_path)


class KittenGroomerPier9(KittenGroomerBase):

    def __init__(self, root_src=None, root_dst=None):
        '''
            Initialize the basics of the copy
        '''
        if root_src is None:
            root_src = os.path.join(os.sep, 'media', 'src')
        if root_dst is None:
            root_dst = os.path.join(os.sep, 'media', 'dst')
        super(KittenGroomerPier9, self).__init__(root_src, root_dst)

        # The initial version will accept all the file extension for all the machines.
        self.authorized_extensions = printers + cnc + shopbot + omax + epilog_laser + metabeam + up

    def _print_log(self):
        '''
            Print the logs related to the current file being processed
        '''
        tmp_log = self.log_name.fields(**self.cur_file.log_details)
        if not self.cur_file.log_details.get('valid'):
            tmp_log.warning(self.cur_file.log_string)
        else:
            tmp_log.debug(self.cur_file.log_string)

    def processdir(self):
        '''
            Main function doing the processing
        '''
        for srcpath in self._list_all_files(self.src_root_dir):
            self.log_name.info('Processing {}', srcpath.replace(self.src_root_dir + '/', ''))
            self.cur_file = FilePier9(srcpath, srcpath.replace(self.src_root_dir, self.dst_root_dir))
            if self.cur_file.extension in self.authorized_extensions:
                self.cur_file.add_log_details('valid', True)
                self.cur_file.log_string = 'Expected extension: ' + self.cur_file.extension
                self._safe_copy()
            else:
                self.cur_file.log_string = 'Bad extension: ' + self.cur_file.extension
            self._print_log()


if __name__ == '__main__':
    main(KittenGroomerPier9, 'Pier 9 version of the KittenGroomer. Only copy some files.')
