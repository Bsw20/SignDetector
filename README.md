# SignDetector
### **Описание:**
Данное клиент-серверное приложение будет использоваться для создания единой базы данных дорожных знаков и возможности редактирования данной базы данных доверенными сотрудниками для определения корректности местоположения каждого дорожного знака. Приложение также поможет избавиться от несанкционированных дорожных знаков.
### **Функции:**
*Регистрации и авторизации 
*Возможность снимать происходящее на дороге и отправлять полученные в ходе использования снимки на сервер. Если не получается отправить сразу же, то снимок должен быть сохранен в буфере и отправлен на сервер по возможности
*Возможность отображение карты со знаками из базы данных, причем пользователь должен уметь выбирать базу данных из данной и заведомо корректной
*Отображение каждого знака различным цветом в зависимости от корректности его постановки
*Возможность сделать фотографию с возможным содержание знака и отправить ее на сервер
*Возможность добавить знак вручную, без фотографии
*Возможность редактировать знаки и фильтровать их
*Кластеризация знаков(Yandex API + кастомная)
## **Стек технологий:**
* **YandexMapsMobile, CoreLocation**
* **SocketIO, Alamofire**
* **AVFoundation**
* **GCD**
* **SnapKit**
* **SwiftyBeaver (logging)**
* * **SwiftyJSON, Decodable**
* * **Kingfisher**
* * **MVC**

## Команда разработчиков
### Backend developer
* Лапшин Даниил (*Node.js, PostgreSQL, Express*)

### IOS developer
* Карпунькин Ярослав (*Swift, UIKit*)
