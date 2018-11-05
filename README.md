# docker-sso
* This docker-compose will automatically set up the `sparcs sso` service for domain `sso-test.sparcs.org`.
* Make sure that the DNS record of `sso-test.sparcs.org` to be equal to the IP address of your host before starting the following jobs.
* You should change the password of users `sysop` and `wheel` by executing the following command at your host:
```shell
sudo docker exec -it sso-server /bin/bash -c "echo SYSOP && passwd sysop && echo WHEEL && passwd wheel"
```
* You should issue and install the certificate for `sso-test.sparcs.org` by executing the follwing command at your host:
```shell
sudo docker exec sso-server /bin/bash -c "\
  /certbot-auto certonly -n --nginx -m wheel@sparcs.org --agree-tos -d sso-test.sparcs.org && \
  rm /etc/nginx/sites-enabled/default && \
  ln -s /etc/nginx/sites-available/sso-test /etc/nginx/sites-enabled/sso-test && \
  service nginx reload && \
  service nginx start"
```
* After finishing the jobs, you should contact the KAIST IC team and change the DNS record of `sparcssso.kaist.ac.kr`.
* Also, you should change the DNS record of `sso.sparcs.org`.
* Issue certificates for `sparcssso.kaist.ac.kr` and `sso.sparcs.org` and
* change the apache config file to use `sso` instead of `sso-test` by executing the following commands
* (do not forget to change the allowed host of the `settings_local.py` file in the container to `sparcssso.kaist.ac.kr`):
```shell
sudo docker exec sso-server /bin/bash -c "\
  service nginx stop && \
  rm /etc/nginx/sites-enabled/sso-test && \
  ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default && \
  /certbot-auto certonly -n --apache -m wheel@sparcs.org --agree-tos -d sparcssso.kaist.ac.kr -d sso.sparcs.org && \
  rm /etc/nginx/sites-enabled/default && \
  ln -s /etc/nginx/sites-available/sso /etc/nginx/sites-enabled/sso && \
  service nginx reload && \
  service nginx start"
```
## Setup
```shell
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo curl -L https://raw.githubusercontent.com/docker/compose/1.23.1/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
git clone https://github.com/sparcs-kaist/docker-sso.git
cd docker-sso
mkdir logs-nginx logs-uwsgi archive db log-backup
```
* The following files should exist in the `./server` directory:
  * `sso`
  * `sso-test`
  * `settings_local.py` (allowed host: `sso-test.sparcs.org`)
  * `sso.ini`
  * `dhparam.pem`
* The following directories should exist in the `./server` directory:
  * `media`
  * `letters`
* The following files should exist in the `./server/scripts` directory:
  * `uwsgi`
  * `renewal.sh`
  * `db.sh`
  * `update.sh`
```shell
sudo docker-compose up -d
```
