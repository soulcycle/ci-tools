import yaml
import sys
import os

yml_content='\n'.join(sys.stdin.readlines())
file_path=sys.argv[1]

def log_inspect(f_path):
    print('-------------------------------------------------------------------------------')
    print('Inspecting the secrets.yml file: {}'.format(f_path))
    print('-------------------------------------------------------------------------------')

def log_error(msg):
    print('[ERROR] - {}'.format(msg))

def log_warn(msg):
    print('[WARN] - {}'.format(msg))

def log_info(msg, label=True):
    if label is False:
        print('{}'.format(msg))
    else:
        print('[INFO] - {}'.format(msg))

'''
Logs out all of the keys under secrets[n].data, but not their values.
'''
def log_secret_data_elem_keys(s_name, data):
    if data is {}:
        log_error('Invalid data field found for secret entry \'{}\' '.format(s_name))
        sys.exit(1)

    log_info('\t\tWith data keys:', label=False)
    
    for key in data.keys():
        log_info('\t\t\t- {}'.format(key), label=False)
    
    return

if __name__ == "__main__":
    log_inspect(file_path)
        
    try:
        contents=yaml.safe_load(yml_content)
    except yaml.YAMLError as exc:
        log_error('Invalid syntax detected in secrets file: {} \n\n{}'.format( file_path, exc))
        sys.exit(1)

    log_info('Successfully loaded yaml file into an object. Not bad...')

    secrets=contents.get('secrets')
    if secrets is None:
        log_warn('Document was parsable as YAML, however there was no \'secrets\' key.')
        sys.exit(0)

    log_info('[INFO] - Found "secrets" key. Looking even better!')

    for s in secrets:
        s_name=s.get('name')
        if s_name is None:
           log_error('Expecting "name" item in secret entry, but it wasn\'t found.')

        log_info('\tFound secret {}'.format(s.get('name')), label=False)
        log_secret_data_elem_keys(s_name, s.get('data', {}))

    log_info('[PASS] Secrets look ok! Moving along.', label=False)
    sys.exit(0)
