import sys
import glob
import os
from subprocess import check_output, CalledProcessError

class ParsingHelpers:
    '''
    Returns a string report of all keys under secrets[n].data, 
    but not their values, because that would be supa-insecure.
    '''
    @staticmethod
    def build_secret_data_keys_rpt(s_name, data):
        r = {
            'secret_keys' : [],
            'error' : '',
            'text_report' : ''
        }

        if data is {}:
            m='Invalid data field found for secret entry \'{}\' '.format(s_name)
            LoggingHelpers.log_error(m)
            r['error'] = m
            return r

        m = LoggingHelpers.log_info('\tWith data keys:\n', label=False, return_str=True)
        # Append to text report output
        r['text_report'] = r['text_report'] +"\n"+ m

        for key in data.keys():
            m = LoggingHelpers.log_info('\t\t- {}\n'.format(key), label=False,  return_str=True)
            r['secret_keys'].append(key)
            # Append data to report
            r['text_report'] = r['text_report'] + m
        
        return r

    @staticmethod 
    def list_files(pattern):
        files = glob.glob("*.yml")
        return files or []

    '''
    Determines which deployment .yml files should be inspected.

    If the file is too small, it will be skipped.
    '''
    @staticmethod
    def get_inspectable_manifests():
        LoggingHelpers.log_info("Finding deployment manifests eligible for inspection.")
        # CWD should contain provisioning/k8s
        manifests = ParsingHelpers.list_files("*.yml")
        # Files with appropriate content length will be in here
        inspectable = []
        for file in manifests:
            LoggingHelpers.log_info('Found file {}'.format(file))
    
            contents=''
            with open(file, mode='r') as f:
                contents = f.read()

            if len(contents) < 1:
                LoggingHelpers.log_error('File {} is very smalLoggingHelpers. Should this file be filled? Exiting.'.format(
                    file
                ))
                sys.exit(1)
            
            # Add file to list for inspection
            inspectable.append(file)

        return inspectable

    '''
    WIP - Will be used to execute a pops command
    '''
    @staticmethod
    def run_pops_command(cmd, label):
        try:
            output = check_output(cmd, shell=True)
            return output
        except CalledProcessError as ex:
            print(
                '{} process exited with a non-zero error code. Error code: {}'.format(
                    label,
                    str(ex.returncode)
                )
            )
            return None

'''
A class to abstract away the actual location of the secrets.yml and values.yml entries
'''
class FileHelpers:

    def __init__(self):
        self.secret_files = self.find_secrets_in_subdir()
        self.values_files = self.find_values_in_subdir()

    '''
    Fetches a list of all secrets.yml files in the cwd
    '''
    def find_secrets_in_subdir(self):
        return glob.glob("./configs/**/secrets.yml")

    '''
    Fetches a list of all secrets.yml files in the cwd
    '''
    def find_values_in_subdir(self):
        return glob.glob("./configs/**/values.yml")

class LoggingHelpers:
    
    @staticmethod
    def show_banner():
        print('''
-------------------------------------------------
|  +-+-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+  |
|  |P|O|P|S| |S|E|C|R|E|T| |V|A|L|I|D|A|T|O|R|  |
|  +-+-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+  |
-------------------------------------------------
''')

    @staticmethod
    def log_inspect(f_path):
        print('\n------------------------------------------')
        print('Inspecting {}'.format(f_path))
        print('--------------------------------------------\n')

    @staticmethod
    def log_results_banner(f_path):
        print('\n----------------------------------------------------------------------')
        print('Results for secrets.yml: {}'.format(f_path))
        print('----------------------------------------------------------------------\n')

    @staticmethod
    def log_error(msg, return_str=False):
        m='[ERROR] - {}'.format(msg)
        if return_str is True:
            return m
        print(m)

    @staticmethod
    def log_warn(msg, return_str=False):
        m='[WARN] - {}'.format(msg)
        if return_str is True:
            return m
        print(m)

    @staticmethod
    def log_info(msg, label=True, return_str=False):
        if label is False:
            m='{}'.format(msg)
        else:
            m='[INFO] - {}'.format(msg)

        if return_str is True:
            return m
        print(m)
