#!/bin/bash
# Attempts to confirm that any pops secrets are decryptable as expected. Not invoked directly as-is
# but instead, as part of secret-validator.sh.

cat <<'eom'
-------------------------------------------------
|  +-+-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+  |
|  |P|O|P|S| |S|E|C|R|E|T| |V|A|L|I|D|A|T|O|R|  |
|  +-+-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+  |
-------------------------------------------------

eom

# CD to where the secrets are expected
cd /home/secrets
echo "Finding secret files..."

secrets=$(find . -type f -regex '.*/configs/.*.secrets.yml')

for file in $secrets; do
    echo "[PENDING] - Testing decryption on $file"
    
    # Is the file NOT encrypted?
    if [[ $(cat $file | grep "ANSIBLE" | wc -l) -ne "1" ]]; then
        echo "[FATAL] - File ${file} isn't encrypted!!"
        exit 1
    fi
    
    echo "File appears to be encrypted. Attempting to decrypt now..."
    secret_contents=$(cat $file | ansible-vault decrypt)
    EC=$?

    if [ "$EC" != "0" ]; then
        echo -e "[FAIL] - Can't decrypt the secrets.yml file for:\n\t$file"
        exit 1
    else
        echo -e "[PASS] - Successfully decrypted $file"
    fi

    # Pass the decrypted vault through stdin to a YAML inspector
    echo -n "${secret_contents}" | python3.6 /usr/src/app/validate-k8s-secrets-yml.py "$file"
    if [ "$?" != "0"  ]; then
        echo -e "[FAIL] - Yaml validation errors detected in: \n\t$file"
        exit 1
    fi
done

if [ ${failure_count} -gt 0 ]; then
    echo "[FATAL] - One or more secrets.yml files weren't encrypted correctly!"
    exit 1
fi

exit 0
