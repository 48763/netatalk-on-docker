# netatalk-on-docker
*Netatalk* 是一款實作 [AFP（Apple Filing Protocol）](https://en.wikipedia.org/wiki/Apple_Filing_Protocol)的免費開源軟體，它允許 *類unix（Unix-like）* 操作系統當作蘋果（Macintosh）電腦的文件服務器。

## 簡介
> 簡介尚未完成

docker images ver 3.1.1
- 3：netatalk 主板號
- 1：使用的 netatalk 版本更新
- 1：dockerfile 變更

netatalk 3.1.12

使用 port 548

## 快速運行

可以使用下面指令，讓 docker 直接從鏡像庫下載 *netatalk:3.1.1* 運行：

```bash
$ sudo docker run --name netatalk -p 548:548 -v data:/data -d lab.yukifans.com/librery/netatalk:3.1.1
```

或是使用 git clone 複製專案，並在本機端建立鏡像檔運行：

```bash
$ git clone https://github.com/48763/netatalk-on-docker.git
$ sudo docker build -t netatalk . 
$ sudo docker run --name netatalk -p 548:548 -v data:/data -d netatalk
```

預設儲存目錄在 `/data`，為了確保數據不隨著容器被刪除，當運行容器時，請使用 `--mount` 或 `--volume`，掛載本地端*目錄*或*匿名卷*以保存數據。

### 連接使用

bonjour 是應用廣播探索服務，所以需要手動設定連接伺服器。
點擊  <img src="img/netatalk-img01.png" width="25px" height="25px">（Finder），使用快捷鍵 `cmd` + `k`，將會跳出連接伺服器的視窗。輸入伺服器位置後連接，再輸入預設的用戶 - `yuki` 和密碼 - `P@ssw0rd` ，就能夠順利登入。

```
afp://192.168.51.59:48763
```

之後再到 Time Machine 選擇硬碟就可以使用並備份。


## 可用參數設定

下面表格為容器運行時， `entrypoint.sh` 所接受使用的環境變數。

| 參數 | 描述 | 預設值 | 參數依賴 |
| -- | -- | -- | -- | 
| USER | 自定義用戶名稱 | yuki | - |
| UID | 設定用戶識別碼 | 1000 | USER |
| GROUP | 自定義用戶群組名稱 | tm | - |
| GID | 設定用戶群組識別碼 | 1000 | GROUP |
| PASSWORD | 變更用戶登入預設密碼 | P@ss2w0rd | - |
| DISABLED | 關閉目錄生成及其權限變更 | - | - |

### USER & GROUP

一般使用時，只需要設置 `USER` 和 `PASSWORD`，就可以創建自己的帳戶進行操作。

```bash
$ sudo docker run \
    --name netatalk \
    -p 548:548 \
    -e USER=new_user_name \
    -e PASSWORD=new_password \
    -d \
    lab.yukifans.com/librery/netatalk:3.1.1
```

當使用 `--mount` 或 `--volume` 掛載目錄時，如果想使用戶輕鬆在本地存取目錄及檔案，可設定用戶的 `UID` 和 `GID`。

```bash
$ sudo docker run \
    --name netatalk \
    -p 548:548 \
    -e USER=new_user_name \
    -e USER=yayuyo \
    -e UID=$(id -u)\
    -e GROUP=devops \
    -e GID=$(id -g) \
    -d \
    lab.yukifans.com/librery/netatalk:3.1.1
```

### DISABLED

如果想要高度變更/操作應用，可以使用 `DISABLED` 來抑制 `entrypoint.sh` 產生和變更目錄。
```
$ sudo docker run \
    --name netatalk \
    -e DISABLED=any_string \
    -d \
    lab.yukifans.com/librery/netatalk:3.1.1
```

## 添加帳戶

在 `afp.conf` 配置檔中，設定目錄使用權限是限制群組，所以只要將新用戶加入至群組就能使用共享目錄。
```
$ sudo docker exec \
    -it \
    netatalk \
    sh -c '
        adduser -D -u 1001 -s /sbin/nologin -G tm -g tm yayuuo
        echo "yayuyo:123" | chpasswd
    '
```

## 配置檔設置

如果想要隨時變更配置，並且不想讓連線中斷，可以使用下面指令。
```
$ sudo docker exec -it netatalk vi /etc/afp.conf
$ sudo docker exec -it netatalk pkill -HUP netatalk
```

## 參考

[1] netatalk, <a href="https://git.alpinelinux.org/aports/tree/community/netatalk/APKBUILD" target="_blank" title="連結替代文字">alpinelinux:netatalk</a>, English

[2] nginxinc, <a href="https://github.com/nginxinc/docker-nginx" target="_blank" title="連結替代文字">docker-nginx</a>, English
