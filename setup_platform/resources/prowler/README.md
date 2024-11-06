# How to Run a Prowler Scan

Documentation: [Tutorials](https://docs.prowler.com/projects/prowler-open-source/en/latest/tutorials/misc/)

1. Set up Docker Compose:
   1. Add credentials to the `.env` file (e.g., for AWS):
      ```shell
      AWS_ACCESS_KEY_ID='xxxx'
      AWS_SECRET_ACCESS_KEY='yyyy'
      ```
   2. Start Docker Compose:
      ```shell
      docker-compose up -d
      ```

2. Run a Prowler scan, for example:
    ```shell
    docker compose exec prowler \
    prowler aws \
    --region us-east-1 \
    --services s3 ec2
    ```
   or
    ```shell
    docker compose exec prowler \
    prowler aws \
    --compliance gdpr_aws
    ```

3. Restart the Prowler dashboard. (The dashboard does not automatically update after a scan.)
    ```shell
    docker compose restart
    ```
