# Terraform AWS ECS ALB

Este módulo crea un Application Load Balancer (ALB) para ser utilizado con servicios ECS en AWS.

## Inputs

| Nombre          | Tipo         | Descripción                                | Requerido |
| --------------- | ------------ | ------------------------------------------ | --------- |
| alb_name        | string       | Nombre del Application Load Balancer       | no        |
| vpc_id          | string       | ID de la VPC donde se desplegará el ALB    | sí        |
| subnet_ids      | list(string) | Lista de IDs de subredes para el ALB       | sí        |
| certificate_arn | string       | ARN del certificado ACM para HTTPS         | no        |
| common_tags     | map(string)  | Etiquetas comunes para aplicar a recursos  | sí        |

## Outputs

| Nombre            | Tipo   | Descripción                               |
| ----------------- | ------ | ----------------------------------------- |
| alb_arn           | string | ARN del ALB                               |
| alb_dns_name      | string | Nombre DNS del ALB                        |
| alb_listener_arn  | string | ARN del listener HTTP del ALB             |
| security_group_id | string | ID del Grupo de Seguridad asociado al ALB |

## Uso

```hcl
module "ecs_alb" {
  source = "github.com/patricio/terraform-aws-ecs-alb"

  alb_name        = "mi-aplicacion-alb"
  vpc_id          = "vpc-123456789"
  subnet_ids      = ["subnet-123456789", "subnet-987654321"]
  certificate_arn = "arn:aws:acm:region:account:certificate/certificate-id"
  
  common_tags = {
    Environment = "production"
    Project     = "mi-proyecto"
    Owner       = "DevOps"
  }
}
```

## Detalles

El módulo crea los siguientes recursos:
- Application Load Balancer
- Grupo de seguridad con reglas para puertos 80 y 443
- Listener HTTP en puerto 80
- Listener HTTPS en puerto 443 (si se proporciona certificate_arn)
- Target Group por defecto

Todos los recursos son etiquetados con los valores proporcionados en `common_tags`.

## Scripts de Prueba

El repositorio incluye scripts para facilitar el proceso de prueba:

### setup-test-infra.sh

Este script configura la infraestructura necesaria para probar el módulo:
- Crea un bucket S3 para almacenar el estado de Terraform
- Configura el versionamiento y cifrado en el bucket
- Crea una tabla DynamoDB para el bloqueo de estado
- Genera un archivo terraform.tfvars con la configuración básica
- Procesa automáticamente los subnet_ids como una lista para Terraform
- Genera un script de limpieza (cleanup-test-infra.sh)

Para utilizarlo:
1. Crea un archivo `.env` con tus variables:
   ```
   AWS_REGION=us-east-1
   VPC_ID=vpc-12345678
   SUBNET_IDS=subnet-123456,subnet-789012
   ```
2. Ejecuta `./setup-test-infra.sh`

### cleanup-test-infra.sh

Este script limpia la infraestructura de prueba creada por setup-test-infra.sh:
- Elimina el bucket S3
- Elimina la tabla DynamoDB

## Requisitos

| Nombre    | Versión   |
| --------- | --------- |
| terraform | >= 0.13.0 |
| aws       | >= 3.0    |