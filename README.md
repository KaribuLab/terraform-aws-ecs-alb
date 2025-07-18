# Terraform AWS ECS ALB

Este módulo crea un Application Load Balancer (ALB) para ser utilizado con servicios ECS en AWS.

## Inputs

| Nombre                        | Tipo         | Descripción                                | Requerido |
| ----------------------------- | ------------ | ------------------------------------------ | --------- |
| alb_name                      | string       | Nombre del Application Load Balancer       | no        |
| alb_internal                  | bool         | Si el ALB es interno o externo             | no        |
| alb_deletion_protection_enabled | bool       | Si la protección contra eliminación está activada | no  |
| vpc_id                        | string       | ID de la VPC donde se desplegará el ALB    | sí        |
| subnet_ids                    | list(string) | Lista de IDs de subredes para el ALB       | sí        |
| certificate_arn               | string       | ARN del certificado ACM para HTTPS         | no        |
| common_tags                   | map(string)  | Etiquetas comunes para aplicar a recursos  | sí        |
| idle_timeout                  | number       | Tiempo de espera en segundos (evita 504)   | no        |

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

  alb_name                      = "mi-aplicacion-alb"
  alb_internal                  = false
  alb_deletion_protection_enabled = true
  vpc_id                        = "vpc-123456789"
  subnet_ids                    = ["subnet-123456789", "subnet-987654321"]
  certificate_arn               = "arn:aws:acm:region:account:certificate/certificate-id"
  idle_timeout                  = 120  # Aumentar el timeout a 2 minutos
  
  common_tags = {
    Environment = "production"
    Project     = "mi-proyecto"
    Owner       = "DevOps"
  }
}
```

## Detalles

El módulo crea los siguientes recursos:
- Application Load Balancer (interno o externo según configuración)
- Grupo de seguridad con reglas para puertos 80 y 443
- Listener HTTP en puerto 80
- Listener HTTPS en puerto 443 (si se proporciona certificate_arn)
- Target Group por defecto

Todos los recursos son etiquetados con los valores proporcionados en `common_tags`.

### Prevención de errores 504 Gateway Timeout

El parámetro `idle_timeout` permite configurar el tiempo en segundos que el ALB mantendrá una conexión inactiva abierta. El valor predeterminado es 60 segundos, pero puede ser aumentado hasta 4000 segundos (66.6 minutos) para evitar errores 504 Gateway Timeout en aplicaciones que requieren más tiempo para completar las solicitudes.

### Protección contra eliminación

La variable `alb_deletion_protection_enabled` permite activar la protección contra eliminación del ALB, lo que evita que se elimine accidentalmente. Esto es útil en entornos de producción donde la eliminación del ALB podría causar interrupciones en el servicio.

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