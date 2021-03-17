# Домашнее задание к занятию "09.03 Jenkins"

## Модуль 9. Система управления конфигурациями

### Студент: Иван Жиляев

## Подготовка к выполнению

>1. Установить jenkins по любой из [инструкций](https://www.jenkins.io/download/)
>2. Запустить и проверить работоспособность
>3. Сделать первоначальную настройку
>4. Настроить под свои нужды
>5. Поднять отдельный cloud
>6. Для динамических агентов можно использовать [образ](https://hub.docker.com/repository/docker/aragast/agent)
>7. Обязательный параметр: поставить label для динамических агентов: `ansible_docker`
>8. Сделать форк репозитория с [playbook](https://github.com/aragastmatb/example-playbook)

Установил jenkins из deb-пакета. Сервис запустился, интерфейс доступен. 

При добавлении docker-engine как провайдера для динамических сред возникла проблема с правами доступа к сокету докера. Добавил пользователя _jenkins_ в группу _docker_ и для применения изменений перезапустил службу jenkins, но этого оказалось недостаточно, а вот перезагрузка системы привела к успеху - cloud docker добавлен.

В меню _Configure Clouds_ произведём настройку динамических агентов в разделе _Docker Agent templates_ созданного cloud:
- в строке _Labels_ указываем требуемый label `ansible_docker`
- в строке _Docker Image_ укажем имя данного образа `aragast/agent:7`

Форк репозитория с playbook доступен по [ссылке](https://github.com/nimlock/netology-example-playbook).

## Основная часть

>1. Сделать Freestyle Job, который будет запускать `ansible-playbook` из форка репозитория

Freestyle Job создал, но при запуске возникла проблема на шаге с ansible-galaxy с доступом до репозитория с ролью - клиент ssh в контейнере не имеет открытого ключа github.com (где расположена роль) в списке доверенных и пытается интерактивно запросить разрешение на добавление, но т.к. сеанс не интерактивный сборка падает.

В качестве решения проблемы добавим config-файл ssh с разрешением на доступ к github.com без наличия его сертификата в списке доверенных хостов. В итоге сборка freestyle состоит из следующих команд:

```
ansible-vault decrypt secret --vault-password-file vault_pass
mkdir -p ~/.ssh/ && mv ./secret ~/.ssh/id_rsa && chmod 400 ~/.ssh/id_rsa
echo -e "Host github.com\n   StrictHostKeyChecking no\n   UserKnownHostsFile=/dev/null" > ~/.ssh/config
ansible-galaxy install -r requirements.yml -p roles
ansible-playbook site.yml -i inventory/prod.yml
```

Приведу окончание консольного вывода успешной сборки:

```
21:23:04 PLAY RECAP *********************************************************************
21:23:04 localhost                  : ok=5    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
21:23:04 

21:23:05 Stopping all containers
21:23:05 Finished: SUCCESS
```

>2. Сделать Declarative Pipeline, который будет выкачивать репозиторий с плейбукой и запускать её

При подготовке Declarative Pipeline добавился шаг по клонированию репозитория, а вторым шагом идёт всё, что было в Freestyle Job. Вот так выглядит пайплайн:

```
pipeline {
    agent {
        label "ansible_docker"
    }

    stages {
        stage('main') {
            steps {
                git 'https://github.com/nimlock/netology-example-playbook.git'
                sh '''ansible-vault decrypt secret --vault-password-file vault_pass
                mkdir -p ~/.ssh/ && mv ./secret ~/.ssh/id_rsa && chmod 400 ~/.ssh/id_rsa
                echo -e "Host github.com\\n   StrictHostKeyChecking no\\n   UserKnownHostsFile=/dev/null" > ~/.ssh/config
                ansible-galaxy install -r requirements.yml -p roles
                ansible-playbook site.yml -i inventory/prod.yml'''
            }
        }
    }
}
```

>3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`
>4. Перенастроить Job на использование `Jenkinsfile` из репозитория

Проблем с выполнением не возникло, т.к. достаточно было создать в [форке](https://github.com/nimlock/netology-example-playbook) Jenkinsfile и перенести pipeline в него. Настройка Job на использование Jenkinsfile из git производится в несколько кликов.

>5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline)
>6. Заменить credentialsId на свой собственный

Для выполнения этих пунктов расшифрованный сертификат для подключения по ssh к репозиторию я добавил в Credentials Jenkins-а в объект с типом _SSH Username with private key_. По какой-то причине он не используется после выгрузки в "~/.ssh/id_rsa" при запуске ansible-galaxy, поэтому я также создал объект типа _Secret file_ с секретом от ansible-vault.

Запуск сборки показал, что в пайплайне отсутствует шаг с "ansible-galaxy install". Исправленный пайплайн выглядит так:

```
node("ansible_docker"){
    stage("Git checkout"){
        git credentialsId: '17feae12-a79e-42d7-a14b-a0f72ea905d2', url: 'git@github.com:aragastmatb/example-playbook.git'
    }
    stage("Prepare ssh key"){
        secret_check=true
    }
    stage("Run playbook"){
        if (secret_check){
            withCredentials([file(credentialsId: '30faa55e-8adb-4841-a196-88d4082047b8', variable: 'SECRET')]) {
                sh '''ansible-vault decrypt secret --vault-password-file ${SECRET}
                mkdir -p ~/.ssh/ && mv ./secret ~/.ssh/id_rsa && chmod 400 ~/.ssh/id_rsa
                echo -e "Host github.com\\n   StrictHostKeyChecking no\\n   UserKnownHostsFile=/dev/null" > ~/.ssh/config
                ansible-galaxy install -r requirements.yml -p roles
                ansible-playbook site.yml -i inventory/prod.yml'''
            }
            
        }
        else{
            echo 'no more keys'
        }
        
    }
}
```

>7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозитрий в файл `ScriptedJenkinsfile`

Создал ещё один Job с использованием скриптованного пайплайна из файла. Сборка прошла удачно.

>8. Отправить ссылку на репозиторий в ответе

Репозиторий доступен по [ссылке](https://github.com/nimlock/netology-example-playbook).

## Необязательная часть

>1. Создать скрипт на groovy, который будет собирать все Job, которые завершились хотя бы раз неуспешно. Добавить скрипт в репозиторий с решеним с названием `AllJobFailure.groovy`
>2. Установить customtools plugin
>3. Поднять инстанс с локальным nexus, выложить туда в анонимный доступ  .tar.gz с `ansible`  версии 2.9.x
>4. Создать джобу, которая будет использовать `ansible` из `customtool`
>5. Джоба должна просто исполнять команду `ansible --version`, в ответ прислать лог исполнения джобы
