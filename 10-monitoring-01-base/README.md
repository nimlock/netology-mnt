# Домашнее задание к занятию "10.01. Зачем и что нужно мониторить"

## Модуль 10. Системы мониторинга

### Студент: Иван Жиляев

## Обязательные задания

>1. Вас пригласили настроить мониторинг на проект. На онбординге вам рассказали, что проект представляет из себя 
>платформу для вычислений с выдачей текстовых отчетов, которые сохраняются на диск. Взаимодействие с платформой 
>осуществляется по протоколу http. Также вам отметили, что вычисления загружают ЦПУ. Какой минимальный набор метрик вы
>выведите в мониторинг и почему?

Я считаю, что в рамках _black-box monitoring_ стоит проверять доступность нашего сервиса "снаружи" по коду ответа http и срок действия сертификата. Данные проверки достаточно легковесны, но при этом могут дать критически важную информацию о доступности сервиса.

Что касается _white-box monitoring_, то я бы предложил настроить базовый мониторинг основных ресурсов платформы и несколько расширенный мониторинг активно потребляемых ресурсов (ЦП, диск, сеть):

- ЦП
  - текущий процент загруженности
  - средние значения загрузки за 1, 5, 10 минут
  - CPU iowait time
- память
  - процент свободной + доступной памяти на хостах
- сеть
  - процент утилизации на интерфейсах по величине траффика в единицах информации и количестве пакетов в единицу времени
  - количество ошибок, коллизий и "дропов" при передаче пакетов
- дисковая подсистема
  - процент свободного места
  - процент свободных inode
  - задержки чтения и записи
  - iops чтения и записи
  - скорости чтения и записи

Данный набор метрик должен покрыть бОльшую часть возможных проблем с платформой. На основе многих из них будет легко настроить пороги сработки алертов, т.к. метрики являют собой базовые параметры работы любой системы и их исчерпание фатально скажется на работе платформы в целом.

>2. Менеджер продукта посмотрев на ваши метрики сказал, что ему непонятно что такое RAM/inodes/CPUla. Также он сказал, 
>что хочет понимать, насколько мы выполняем свои обязанности перед клиентами и какое качество обслуживания. Что вы 
>можете ему предложить?

Нам необходимо дополнить мониторинг бизнес-метриками. Запросив у менеджера подробности SLA можно будет вывести текущие значения SLI, "зашив" формулу(-ы) расчёта в систему мониторинга.

Также, можно организовать цвето-графическую сводную панель, которая будет интерпретировать метрики технического мониторинга в "человеческие" значения по типу "всё отлично", "есть проблемы" или "всё пропало" для каждого участка мониторинга.

>3. Вашей DevOps команде в этом году не выделили финансирование на построение системы сбора логов. Разработчики в свою 
>очередь хотят видеть все ошибки, которые выдают их приложения. Какое решение вы можете предпринять в этой ситуации, 
>чтобы разработчики получали ошибки приложения?

Возможным компромиссом может стать организация сбора логов в усечённом формате на имеющихся мощностях. То есть можно снизить глубину хранения логов, их уровень (оставив только часть событий, например, ошибки), отключить возможность полнотекстового поиска по логам и различные индексирования.  
Также может оказаться приемлемым отказ от части предлагаемого стека инструментов для мониторинга, например, от web-интерфейса.

В качестве альтернативы можно организовать хранение и обработку логов на рабочих станциях самих разработчиков, это вполне допустимо в случае тестовых стендов приложений. Будет удобно использовать службу очередей сообщений с подпиской на события, когда разработчики в своих локальных инстансах системы мониторинга могут отметить логи каких конкретно приложений они хотели бы получать.

>3. Вы, как опытный SRE, сделали мониторинг, куда вывели отображения выполнения SLA=99% по http кодам ответов. 
>Вычисляете этот параметр по следующей формуле: summ_2xx_requests/summ_all_requests. Данный параметр не поднимается выше 
>70%, но при этом в вашей системе нет кодов ответа 5xx и 4xx. Где у вас ошибка?

По таким исходным данным могу сделать единственное предположение: логика приложения активно использует перенаправления, которые генерируют коды ответа из группы 3xx. В таком случае нужно учесть их в формуле просуммировав их общее количество с количеством ответов 2xx в числителе.

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

>Вы устроились на работу в стартап. На данный момент у вас нет возможности развернуть полноценную систему 
>мониторинга, и вы решили самостоятельно написать простой python3-скрипт для сбора основных метрик сервера. Вы, как 
>опытный системный-администратор, знаете, что системная информация сервера лежит в директории `/proc`. 
>Также, вы знаете, что в системе Linux есть  планировщик задач cron, который может запускать задачи по расписанию.
>
>Суммировав все, вы спроектировали приложение, которое:
>- является python3 скриптом
>- собирает метрики из папки `/proc`
>- складывает метрики в файл 'YY-MM-DD-awesome-monitoring.log' в директорию /var/log 
>(YY - год, MM - месяц, DD - день)
>- каждый сбор метрик складывается в виде json-строки, в виде:
>  + timestamp (временная метка, int, unixtimestamp)
>  + metric_1 (метрика 1)
>  + metric_2 (метрика 2)
>  
>     ...
>     
>  + metric_N (метрика N)
>  
>- сбор метрик происходит каждую 1 минуту по cron-расписанию
>
>Для успешного выполнения задания нужно привести:
>
>а) работающий код python3-скрипта,
>
>б) конфигурацию cron-расписания,
>
>в) пример верно сформированного 'YY-MM-DD-awesome-monitoring.log', имеющий не менее 5 записей,
>
>P.S.: количество собираемых метрик должно быть не менее 4-х.
>P.P.S.: по желанию можно себя не ограничивать только сбором метрик из `/proc`.

