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
cd /home/secrets

echo "Finding secret files..."
# echo "Using vault password file: $ANSIBLE_VAULT_PASSWORD_FILE"

secrets=$(find . -type f -regex '.*/configs/.*.secrets.yml')
failure_count=0
for file in $secrets; do
    echo "[PENDING] - Testing decryption on $file"
    
    # Is the file NOT encrypted?
    if [[ $(cat $file | grep "ANSIBLE" | wc -l) -ne "1" ]]; then
        echo "[FATAL] - File ${file} isn't encrypted!!"
        failure_count=$((failure_count + 1))
    fi
    
    echo "File appears to be encrypted. Attempting to decrypt now..."
    # chmod 0600 $file
    ansible-vault -vvvvv decrypt $file
    if [ "$?" != "0" ]; then
        echo -e "[FAIL] - Can't decrypt the secrets.yml file for:\n\t$file"
        failure_count=$((failure_count + 1))
    else
        echo -e "[OK] - Successfully decrypted $file"
    fi
done

if [ ${failure_count} -gt 0 ]; then
    echo "[FATAL] - One or more secrets.yml files weren't encrypted correctly!"
    exit 1
fi

exit 0
