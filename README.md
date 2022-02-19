# TODO

1. VPC - 2 subnets, & internet gateway - couche layer "network" - module
2. RDS - 1 db t3.nano, 1 IAM user "dba" - couche layer "landscape" - module
3. test app deployment
   - Ou sont les fichiers publics à mettre dans le S3/Cloudfront ?
   - Y a-t-il besoin de mettre un webserver (nginx ?) devant la webapp pour servir les fichiers statiques ?
4. Mettre en place les métriques cloudwatch d'autoscaling
   - processeur >= 80%
   - RAM >= 80%
   - Hard disk >= 80%
5. Alerting EC2



# terminer la stack database
créer les users
sécuriser le VPc et donc la DB
