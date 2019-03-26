#!/usr/bin/python

import os
import sys
from helpers import ParsingHelpers as p
from helpers import LoggingHelpers as l

from secretvalidator import SecretValidators as sv
from helpers import FileHelpers

if __name__ == "__main__":
    
    # Change directories to where provisioning/k8s will be mounted
    os.chdir(os.environ.get('WORKING_DIR', '/home/secrets'))

    # Load available secrets.yml, values.yml and k8s manifests
    deploy_info = FileHelpers()
    
    # Decrypt them and return the results
    secrets_report = sv.get_decrypted_secrets(deploy_info.secret_files)

    # Add further validation commands here...
    l.log_info('\n\nEvaluating results...', label=False)
    failure_count=0
    for result in secrets_report:
        # Happy path
        l.log_results_banner(result['secrets_file'])
        warnings = result.get('warnings', '')
        if result.get('errors') is '':
            # Cool, no errors. Any warnings or are we all good?
            if len(warnings) > 0:
                l.log_info(
                    '[OK w/ Warnings] - ................... {}'.format(result['secrets_file']), label=False
                )
                l.log_info('\n\tWarnings: \n\t{}'.format(warnings), label=False)
            else:
                l.log_info(
                    '[OK] - ......................... {}'.format(result['secrets_file']), label=False
                )
        else:
            l.log_error(
                '....................... {}'.format(result['secrets_file'])
            )
            l.log_info('\tFailed with errors: \n\t{}'.format(
                result.get('errors', '')
            ), label=False)
            failure_count = failure_count + 1

        # Print out data key report
        data_key_rpt = result.get('data_key_report', '') 
        if len(data_key_rpt) > 0:
            l.log_info('\n{}'.format(data_key_rpt), label=False)

    # Determine exit code
    if failure_count > 0:
        l.log_error('One or more secrets were flagged as being invalid. Exiting with error!')
        sys.exit(1)

    l.log_info('[PASS] Secrets look ok! Moving along.', label=False)
    sys.exit(0)
