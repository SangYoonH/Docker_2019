# docker-CD
## < 프로젝트 실행방법 >


#### 1. Docker를 설치하고, Bash script를 실행할 수 있는 환경을 준비한다. 

> -실행 스크립트는 bash 스크립트로 작성하였습니다.

#### 2. 홈 디렉토리(~/Apps/)에 위치한 devops.sh의 usage를 확인합니다.

> ex)[id@hostname Apps]$ ./devops.sh -h

-h 옵션을 사용하거나, [start/stop/restart/deploy] 이외의 command를 사용하면 스크립트 usage가 print 됩니다.

#### 3. 'start' command를 통해 컨테이너 환경을 전체 실행 합니다.

> ex)[id@hostname Apps]$ ./devops.sh start

- 스크립트와 같은 경로에 있는 docker-compose.yml 및 각 Dockerfile 들을 통해

1)Spring boot code를 빌드할 수 있는 **gradle** 이미지


2)Spring boot code의 구동 환경이 디는 **java(jdk)** 이미지


3)reverse proxy와 round-robin 로드밸런싱 기능을 수행하는 **nginx** 이미지

들을 가져오고 docker 명령어 및 설정에 따라 총 3개의 container가 최초 생성됩니다.
> 2개의 웹 어플리케이션 container( 각 container에서 8080 port로 기동됩니다. ) + ngnix를 구동하는 container

#### 4. 정상적으로 전체 실행 되었다면, 'docker container ps' 명령어로 출력되는 화면을 통해 3개 container가 구동된 것을 확인할 수 있습니다.

- 기동 후, browser에서 같은 내용으로 build된 서로 다른 두 spring-boot app이 round-robin 형식으로 로드밸런싱 되는 것을 확인할 수 있습니다.
- 또한, docker-compose 파일안에서 'volumes'를 활용하여 nginx에서 발생하는 accesslog를 호스트에 파일 형식으로 write하는 기능도 볼 수 있다.
> start 후, 호스트 경로의 ~/Apps/logs 디렉토리에서 확인 가능 

- 캐싱 기능을 비활성화 하고, 웹브라우져에서 새로고침 버튼을 누르면 한 컨테이너 씩 번갈아 로드밸런싱이 이루어 집니다.

> docker.compose 파일에 설정된 link 기능을 통해 nginx,container1,container2 가 container 이름을 기준으로 서로를 판별할 수 있고 웹 서버이자 로드 밸런서 기능을 하는 nginx가 WAS 역할을 하는 각 Tomcat의 부하를 분산 시켜주는 형태입니다.

> 웹 브라우져 상 1번, 2번으로 요청되었다라고 간단히 표출하게 해 놓았고 표출되는 string은 다르지만 같은 역할을 하는 application이라고 봐주시면 됩니다. (User 입장에서는 하나의 interface를 사용하는 느낌)

#### 5. 'stop' command를 통해 컨테이너 환경을 전체 중지 할 수 있습니다.

> ex)[id@hostname Apps]$ ./devops.sh stop

- 환경에 아무런 container가 기동되어있지 않다면, 에러메세지를 표출합니다.

#### 6. 'restart' command를 통해 컨테이너 환경 전체를 재시작 할 수 있습니다.

> ex)[id@hostname Apps]$ ./devops.sh restart


#### 7. 'deploy' command를 통해 무중단 배포가 이루어 집니다. 

> ex)[id@hostname Apps]$ ./devops.sh deploy

- blue(app container group 1) / green (app container group 2) 배포방식을 사용


##### <deploy 상세 사용 방법 >
1)app에 새롭게 반영할 사항이 생겨 deploy가 필요하다면, src 폴더 하위에 app contents를 추가한다.

2) 그리고 ./devops.sh 스크립트를 실행한다.



#### 8. scale out 기능

- 여러 구현 방안을 고민하다가, 일단 옵션 command로 기능을 제공하기로 결정하였습니다. 

> [id@hostname Apps]$ ./devops.sh scaleout '추가 하고 싶은 container 개수'

> ex) ./devops.sh scaleout 3

- 위의 예시와 같이 스크립트를 수행하면, docker-compose up --scale 기능을 통해 정한 개수 만큼 container가 scale out 됩니다.











