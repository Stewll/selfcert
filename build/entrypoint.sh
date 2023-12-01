#!/bin/bash

# Read Configuration
source crt.conf

# Clean up
rm -rf r/


# Create Directories
mkdir -p r/Keys
mkdir -p r/CAcerts
mkdir -p r/certs
mkdir -p r/CSR
mkdir -p r/Pass

# Generate Root Key                 r/Keys/rootCA.key
openssl genpkey -algorithm RSA -out r/Keys/rootCA.key -aes256 -pass pass:$ROOT_KEY_PASS
# Create Root Certificate
openssl req -x509 -new -nodes -key r/Keys/rootCA.key \
    -sha256 -days 1 -out r/CAcerts/root.pem -passin pass:$ROOT_KEY_PASS \
    -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORG_UNIT/CN=$COMMON_NAME"

# Generate CSR Key
openssl genpkey -algorithm RSA -out r/Keys/csr.key -aes256 -pass pass:$CSR_KEY_PASS

# Generate CSR
openssl req -new -key r/Keys/csr.key -out r/CSR/csr.csr -passin pass:$CSR_KEY_PASS \
    -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORG_UNIT/CN=$COMMON_NAME"

# Sign CSR with Root CA
openssl x509 -req -in r/CSR/csr.csr -CA r/CAcerts/root.pem -CAkey r/Keys/rootCA.key \
    -CAcreateserial -out r/certs/certificate.crt -days 500 -sha256 -passin pass:$ROOT_KEY_PASS

#Spit out the certificates, r/keys, passwords and CSRs to the console
echo "Root Key: id_rsa_root"  
cat r/Keys/rootCA.key
echo ""
echo "CSR Key: id_rsa_csr"
cat r/Keys/csr.key
echo ""
echo "Certificate Signing Request: csr.csr"
cat r/CSR/csr.csr
echo ""
echo "Root Certificate: root.pem"
cat r/CAcerts/root.pem
echo ""
echo "Signed Certificate: certificate.crt"
cat r/certs/certificate.crt
echo ""
echo "Tarball Password: $ROOT_KEY_PASS"
# Create the encrypted tarball of the r/keys and certs.
tar -czvf certs.tar.gz r/Keys/ r/CAcerts/ r/certs/ r/CSR/ crt.conf r/Pass/ 2>&1 > /dev/null
openssl enc -pbkdf2 -aes-256-cbc -md sha512 -salt \
-in certs.tar.gz -out r/certs.tar.gz.enc -pass pass:$ROOT_KEY_PASS
# Spit out how to decrypt the tarball to the console
echo "To decrypt the tarball, run the following command:"
echo "openssl enc -pbkdf2 -aes-256-cbc -md sha512 -d -salt \\
    -in Results/certs.tar.gz.enc -out certs.tar.gz -pass pass:$ROOT_KEY_PASS" 
echo ""
echo "Root Key Password: $ROOT_KEY_PASS" && echo $ROOT_KEY_PASS > r/rootCA.key.pass
echo "CSR Key Password: $CSR_KEY_PASS" && echo $CSR_KEY_PASS > r/csr.key.pass

# Clean up
rm -rf r/Keys/ r/CAcerts/ r/certs/ r/CSR/ /crt.conf r/certs.tar.gz r/rootCA.key.pass r/csr.key.pass r/Pass/

# Exit
exit 0

