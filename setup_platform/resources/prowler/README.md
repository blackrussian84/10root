# How to run Prowler scan

Documentation: [tutorials](https://docs.prowler.com/projects/prowler-open-source/en/latest/tutorials/misc/)

1. Run docker compose 
   1. Add credentials to `.env` file. ex: for AWS
      ```shell
      AWS_ACCESS_KEY_ID='xxxx'
      AWS_SECRET_ACCESS_KEY='yyy'
      ```
    2. Run docker-compose
        ```shell
        docker-compose up -d
        ```
2. Run Prowler scan, ex:
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
3. Restart prowler dashboard. For some reason, dashboard do not automatically update after scan.
    ```shell
    docker compose restart
    ```
