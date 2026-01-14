# Test Module with Complex Secrets

Terraform модуль для тестирования сложных объектов с секретами.

## Описание

Этот модуль демонстрирует работу со сложными вложенными объектами, содержащими секретные данные:
- `my_secret1` - простой строковый секрет (например, API ключ)
- `my_secret2` - объект с секретными данными (username/password)

## Структура переменной с секретами

```hcl
mixed_object_with_secrets = {
  enabled   = bool
  timeout   = number
  endpoints = list(string)
  metadata = {
    environment = string
    region      = string
  }
  my_secret1 = string              # Секретный API ключ
  my_secret2 = {                   # Секретные учетные данные
    username = string
    password = string
  }
}
```

## Использование

### 1. Базовое использование

```hcl
module "test_with_secrets" {
  source = "./test_module_with_complex_secrets"

  string_expression = "https://api.example.com"
  
  policy_config = {
    version = "2.0"
    rules = [
      {
        action   = "allow"
        resource = "arn:aws:s3:::my-bucket/*"
      }
    ]
  }
  
  array_value   = ["value1", "value2"]
  boolean_value = true
  number_value  = 42
  
  mixed_object_with_secrets = {
    enabled  = true
    timeout  = 300
    endpoints = ["https://api.example.com"]
    metadata = {
      environment = "production"
      region      = "us-east-1"
    }
    my_secret1 = "secret-api-key"
    my_secret2 = {
      username = "admin"
      password = "secure-password"
    }
  }
}
```

### 2. Использование с переменными окружения

```bash
# Установить секреты через переменные окружения
export TF_VAR_api_secret="my-secret-key"
export TF_VAR_db_password="secure-password"

terraform apply
```

### 3. Использование с AWS Secrets Manager

```hcl
data "aws_secretsmanager_secret_version" "api_key" {
  secret_id = "prod/api/key"
}

data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = "prod/database/credentials"
}

locals {
  api_secret = jsondecode(data.aws_secretsmanager_secret_version.api_key.secret_string)
  db_creds   = jsondecode(data.aws_secretsmanager_secret_version.db_creds.secret_string)
}

module "test_with_secrets" {
  source = "./test_module_with_complex_secrets"
  
  # ... другие переменные ...
  
  mixed_object_with_secrets = {
    enabled  = true
    timeout  = 300
    endpoints = ["https://api.example.com"]
    metadata = {
      environment = "production"
      region      = "us-east-1"
    }
    my_secret1 = local.api_secret.key
    my_secret2 = {
      username = local.db_creds.username
      password = local.db_creds.password
    }
  }
}
```

## Входные переменные

| Имя | Описание | Тип | Обязательно | Sensitive |
|-----|----------|-----|-------------|-----------|
| string_expression | String prop with expression | string | yes | no |
| policy_config | Policy configuration object | object | yes | no |
| array_value | Array prop value | list(string) | yes | no |
| boolean_value | Boolean prop value | bool | yes | no |
| number_value | Number prop value | number | yes | no |
| mixed_object_with_secrets | Object with secrets | object | yes | **yes** |

## Выходные данные

| Имя | Описание | Sensitive |
|-----|----------|-----------|
| mixed_object_metadata | Non-sensitive metadata | no |
| secret1_exists | Check if secret1 is provided | no |
| secret2_username | Username from secret2 | **yes** |
| secrets_hash | MD5 hashes of secrets | no |

## 🔐 Безопасность

### Важные моменты:

1. **Переменная помечена как sensitive:**
   ```hcl
   variable "mixed_object_with_secrets" {
     # ...
     sensitive = true
   }
   ```

2. **Никогда не коммитьте файлы с секретами:**
   ```bash
   # Добавьте в .gitignore
   *.tfvars
   !*.tfvars.example
   terraform.tfstate
   terraform.tfstate.backup
   .terraform/
   ```

3. **Используйте хеши для верификации:**
   ```bash
   terraform output secrets_hash
   # Output:
   # {
   #   "secret1_hash" = "5d41402abc4b2a76b9719d911017c592"
   #   "secret2_hash" = "098f6bcd4621d373cade4e832627b4f6"
   # }
   ```

4. **Храните секреты в защищенных хранилищах:**
   - AWS Secrets Manager
   - HashiCorp Vault
   - Azure Key Vault
   - Google Secret Manager

## Примеры

### Пример 1: Development окружение

```hcl
mixed_object_with_secrets = {
  enabled  = true
  timeout  = 60
  endpoints = ["http://localhost:3000"]
  metadata = {
    environment = "development"
    region      = "local"
  }
  my_secret1 = "dev-api-key-123"
  my_secret2 = {
    username = "dev_user"
    password = "dev_password"
  }
}
```

### Пример 2: Production окружение с реальными секретами

```hcl
mixed_object_with_secrets = {
  enabled  = true
  timeout  = 300
  endpoints = [
    "https://api.prod.example.com",
    "https://api-backup.prod.example.com"
  ]
  metadata = {
    environment = "production"
    region      = "us-east-1"
  }
  my_secret1 = var.api_key_from_secrets_manager
  my_secret2 = {
    username = var.db_username
    password = var.db_password
  }
}
```

## Тестирование

```bash
# Создать terraform.tfvars из примера
cp terraform.tfvars.example terraform.tfvars

# Отредактировать секреты
vim terraform.tfvars

# Инициализация
terraform init

# Планирование
terraform plan

# Применение
terraform apply

# Проверить выходные данные (секреты будут скрыты)
terraform output

# Проверить хеши секретов
terraform output secrets_hash
```

## Очистка

```bash
# Удалить все ресурсы
terraform destroy

# Очистить файлы с секретами
rm terraform.tfvars
rm -rf .terraform
rm terraform.tfstate*
```

## Рекомендации

1. ✅ Всегда используйте `sensitive = true` для переменных с секретами
2. ✅ Храните секреты в защищенных хранилищах
3. ✅ Используйте `.gitignore` для файлов с секретами
4. ✅ Ротируйте секреты регулярно
5. ✅ Используйте хеши для верификации без раскрытия секретов
6. ❌ Никогда не коммитьте `.tfvars` с реальными секретами
7. ❌ Не логируйте секреты в output
8. ❌ Не храните секреты в plain text в репозитории
