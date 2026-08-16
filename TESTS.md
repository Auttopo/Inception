
  Then retry the FTP test commands:

    # 1. Test directory listing
    curl -u ftpuser:ftppassword ftp://127.0.0.1:21/

    # 2. Upload test file
    echo "Hello from FTP" > /tmp/ftp_sample.txt
    curl -u ftpuser:ftppassword -T /tmp/ftp_sample.txt ftp://127.0.0.1:21/ftp_sample.txt

    # 3. Verify on WordPress container
    sudo docker exec -it $(sudo docker ps -qf "name=wordpress") cat /home/abenabde/data/ftp_sample.txt

