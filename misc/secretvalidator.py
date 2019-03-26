import yaml
import sys
import os
from helpers import LoggingHelpers as l
from helpers import ParsingHelpers as p
from subprocess import check_output, CalledProcessError, STDOUT

class SecretValidators:

    '''
    Retrieves the 'secrets' key from the loaded Secrets.yml
    '''
    @staticmethod
    def get_secrets_key_value(yml_obj):
        r = {
            'data' : None,
            'error' : '',
            'warning' : ''
        }
        l.log_info('Attempting to retrieve \'secrets\' key from secrets.yml....')

        if yml_obj is {}:
            m='Failed to render object from decrypted secrets.yml. That\'s not good!'
            l.log_error(m)
            r['error']=m
            return r
        elif yml_obj is None:
            # Blank object, i.e. ---
            m='Document was parsable as YAML but there isn\'t any data.'
            l.log_warn(m)
            r['warning']=m
            return r

        secrets=yml_obj.get('secrets', None)
        r['data']=secrets
        if secrets is None:
            m='Document was parsable as YAML, however there was no \'secrets\' key.'
            l.log_warn(m)
            r['warning']=m
        else:
            l.log_info('Found "secrets" key. Looking even better!')        

        return r

    '''
    Attempts to decrypt all of the secrets in secrets_path_list. Returns a list of
    objects which contain the results of our decryption attempts.
    '''
    @staticmethod
    def get_decrypted_secrets(secrets_path_list):
        l.show_banner()
        # If there aren't any secrets, let's just skip out.
        secret_objects=[]
        if secrets_path_list is []:
            sys.exit(0)
        for yml_file_path in secrets_path_list:
            l.log_inspect(yml_file_path)
            l.log_info('Preparing to test decryption on {}'.format(yml_file_path))
            error=''
            warning=''
            with open(yml_file_path, 'r') as y:
                content = y.readlines()
            
            string_contents = ''.join(content)
            # Make sure it's encrypted to begin with
            if '$ANSIBLE_VAULT;' not in string_contents:
                l.log_error('[FATAL] - File {} isn\'t encrypted!!'.format(
                    yml_file_path
                ))
                error = error + 'File is not encrypted!!!'
                # Index the object with collected metadata
                secret_objects.append({
                    'secrets_file' : yml_file_path,
                    'encrypted' : string_contents,
                    'raw' : '',
                    'yaml_obj' : {},
                    'errors' : error
                })
            else:
                # Let's try to decrypt it
                results = SecretValidators.decrypt_ansible_vault(yml_file_path)
                yaml_obj={}
                secrets_key={}
                data_key_report=""
                # Collect any errors
                if results['errors'][0] is not '':
                    error = error + results['errors'][0]
                else:
                    print('[PASS] - Successfully decrypted {}!'.format(yml_file_path))
                    # Load YAML into an object
                    yaml_obj = SecretValidators.load_decrypted_secret_yml(results['output'], yml_file_path).get('yml_obj')
                    # Extract 'secrets' from yaml object
                    secrets_key = SecretValidators.get_secrets_key_value(yaml_obj)
                    if secrets_key.get('data') is not None:
                        # Append 'secret' to yaml_obj we're building
                        yaml_obj['secrets_key']=secrets_key['data']
                        # Pull out data keys in object since they could be of interest
                        # e.g. example-db-creds.username
                        secret_data_keys = SecretValidators.analyze_secrets(yaml_obj['secrets_key'])
                        data_key_report = data_key_report + secret_data_keys.get('report')
                        
                    # Track errors and warnings
                    if yaml_obj is not None:
                        error = error + yaml_obj.get('error', '')
                    if secrets_key is not None:
                        error = error + secrets_key.get('error', '')
                    if len(secrets_key.get('warning','')) > 0:
                        warning = warning + secrets_key.get('warning','')

                # Index the object with collected metadata
                secret_objects.append({
                    'secrets_file' : yml_file_path,
                    'encrypted' : string_contents,
                    'raw' : results.get('output'),
                    'yaml_obj' : yaml_obj,
                    'errors' : error,
                    'warnings' : warning,
                    'data_key_report' : data_key_report
                })
        
        return secret_objects

    '''
    Runs the ansible-vault decrypt command and returns an dictionary
    that describes its results.
    '''
    @staticmethod
    def decrypt_ansible_vault(secrets_file):
        result = {
            'exit_code' : 0,
            'errors' : [''],
            'output' : ''
        }
        try:
            cmd = 'cat {} | ansible-vault decrypt'.format(secrets_file)
            output = check_output(cmd, stderr=STDOUT, shell=True)
            result['output'] = output
        except CalledProcessError as ex:
            l.log_error(
                'Failed to decrypt the secrets.yml file for:\n\t{}'.format(
                    secrets_file
                )
            )
            result['exit_code'] = ex.returncode
            result['errors'][0] = str(ex.output)
        
        return result
    
    '''
    Load up the decrypted secret yaml and convert it into an object.

    Returns:
    {
        'yml_obj' : [dict],
        'error' : [str]
    }
    '''
    @staticmethod
    def load_decrypted_secret_yml(yml_content, secrets_file):
        r = {
            'yml_obj' : {},
            'error' : ''
        }
        try:
            obj = yaml.safe_load(yml_content)
            l.log_info('Successfully loaded yaml file into an object. Not bad...')
            r['yml_obj'] = obj
        except yaml.YAMLError as exc:
            l.log_error('Invalid syntax detected in secrets file: {} \n\n{}'.format(secrets_file, exc))
            r['error'] = exc.message

        return r



    @staticmethod
    def analyze_secrets(secrets):
        # Skip - no work to do
        errors=''
        report_list=[]
        if secrets is None or secrets is {}:
            l.log_info('No "secrets" found, so skipping analysis.')
            return { 'error' : '', 'report' : '' }

        for secret in secrets:
            # Loop through data kvps
            data_objs=secret.get('data', {})
            s_name = secret.get('name')
            if s_name is None:
                m='Expecting "name" item in secret entry, but it wasn\'t found.'
                l.log_error(m)
                errors = errors + m
            else:
                # l.log_info('\tFound secret {}'.format(s_name), label=False)
                message = 'Found secret "{0}": {1}'.format(
                    s_name, p.build_secret_data_keys_rpt(s_name, data_objs).get('text_report', '')
                )
                report_list.append(message)

        return { 'error' : errors, 'report' : '\n'.join(report_list) }
