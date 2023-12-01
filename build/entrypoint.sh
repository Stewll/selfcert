#!/bin/bash

# Read Configuration
source crt.conf

# Clean up
rm -rf Results/


# Create Directories
mkdir -p Results/Keys
mkdir -p Results/CAcerts
mkdir -p Results/certs
mkdir -p Results/CSR
mkdir -p Results/Pass

# Generate Root Key                 Results/Keys/rootCA.key
openssl genpkey -algorithm RSA -out Results/Keys/rootCA.key -aes256 -pass pass:$ROOT_KEY_PASS
# Create Root Certificate
openssl req -x509 -new -nodes -key Results/Keys/rootCA.key \
    -sha256 -days 1 -out Results/CAcerts/root.pem -passin pass:$ROOT_KEY_PASS \
    -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORG_UNIT/CN=$COMMON_NAME"
# Generate CSR Key
openssl genpkey -algorithm RSA -out Results/Keys/csr.key -aes256 -pass pass:$CSR_KEY_PASS
# Generate CSR
openssl req -new -key Results/Keys/csr.key -out Results/CSR/csr.csr -passin pass:$CSR_KEY_PASS \
    -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORG_UNIT/CN=$COMMON_NAME"
# Sign CSR with Root CA
openssl x509 -req -in Results/CSR/csr.csr -CA Results/CAcerts/root.pem -CAkey Results/Keys/rootCA.key \
    -CAcreateserial -out Results/certs/certificate.crt -days 500 -sha256 -passin pass:$ROOT_KEY_PASS


#Spit out the certificates, keys, passwords and CSRs to the console
echo "Root Key: id_rsa_root"  
cat Results/Keys/rootCA.key
echo ""
echo "CSR Key: id_rsa_csr"
cat Results/Keys/csr.key
echo ""
echo "Certificate Signing Request: csr.csr"
cat Results/CSR/csr.csr
echo ""
echo "Root Certificate: root.pem"
cat Results/CAcerts/root.pem
echo ""
echo "Signed Certificate: certificate.crt"
cat Results/certs/certificate.crt
echo ""
echo "Tarball Password: $ROOT_KEY_PASS"
# Create the encrypted tarball of the Results/keys and certs.
tar -czf certs.tar.gz Results/ crt.conf  && openssl enc -pbkdf2 -aes-256-cbc -md sha512 -salt -in certs.tar.gz -out Results/certs.tar.gz.enc -pass pass:$ROOT_KEY_PASS
# Spit out how to decrypt the tarball to the console
echo "To decrypt the tarball, run the following command:"
echo "openssl enc -pbkdf2 -aes-256-cbc -md sha512 -d -salt -in Results/certs.tar.gz.enc -out certs.tar.gz -pass pass:$ROOT_KEY_PASS" 
echo ""
echo "Root Key Password: $ROOT_KEY_PASS" && echo $ROOT_KEY_PASS > Results/rootCA.key.pass
echo "CSR Key Password: $CSR_KEY_PASS" && echo $CSR_KEY_PASS > Results/csr.key.pass

# Clean up
rm -rf Results/ crt.conf 

# Exit
exit 0

