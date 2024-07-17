FROM mcr.microsoft.com/dotnet/sdk:7.0
WORKDIR /App
## Arguments for setting the Sonarqube Token and the Project Key
ARG SONAR_TOKEN  
ARG SONAR_BACKEND_API_PROJECT_KEY 

## Setting the Sonarqube Organization and Uri
ENV SONAR_ORG "MuskaanDreams"
ENV SONAR_HOST "https://sonarcloud.io/"

## Install Java, because the sonarscanner needs it.
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y openjdk-17-jre && apt-get install -y libxml2 
## Install sonarscanner
RUN dotnet tool install --global dotnet-sonarscanner --version 6.1.0

##Install dotnet-coverage
RUN dotnet tool install --global dotnet-coverage

## Set the dotnet tools folder in the PATH env variable
ENV PATH="${PATH}:/root/.dotnet/tools"

## Start scanner
RUN dotnet sonarscanner begin \
	/o:"$SONAR_ORG" \
	/k:"$SONAR_BOT_AP_BACKEND_API_PRJ_KEY" \
	/d:sonar.host.url="$SONAR_HOST" \
	/d:sonar.token="$SONAR_TOKEN" \ 
	/d:sonar.exclusions="**/abcBotApi/Controllers/**,**/abcBotApi/Repository/**,**/abcBotApi/Models/**,**/abcBotApi/Constants/**,**/abcBotApi/Mapper/**, **/abcBotApi/Contracts/**, **/abcBotApi/Credentials/**, **/abcBotApi/Helper/**" \
	/d:sonar.cs.vscoveragexml.reportsPaths="coverage.xml"

# Copy everything
COPY . ./

## Build the app and collect coverage
RUN dotnet build && \
    dotnet test && \
    dotnet-coverage collect "dotnet test" -f xml -o "coverage.xml"
 
## Stop scanner
RUN dotnet sonarscanner end /d:sonar.token="$SONAR_TOKEN"
EXPOSE 5184
CMD ["dotnet", "run","--project","MuskaanDreamsAPI"]