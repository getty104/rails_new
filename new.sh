if [ $# -lt 2 ]; then
  echo "usage" 1>&2
  echo "rails_new app_name mode --options" 1>&2
  echo "mode" 1>&2
  echo "normal          normal app" 1>&2
  echo "normal-webpack  normal app with webpack" 1>&2
  echo "api             api app" 1>&2
  echo "api-webpack     api app with webpack" 1>&2
  echo "options" 1>&2
  echo "--docker        use docker" 1>&2
  echo "--react         use react(webpack must)" 1>&2
  exit 1
fi

case $2 in

  normal)
    rails new $1 --database=mysql --skip-turbolinks --skip-test
    cd ./$1
    cp -f ~/programming/Scripts/rails_new/tools/Gemfile_normal ./Gemfile ;;

  normal-webpack)
    rails new $1 --database=mysql --skip-turbolinks --skip-test --webpack
    cd ./$1
    cp -f ~/programming/Scripts/rails_new/tools/Gemfile_normal ./Gemfile
    echo "#webpack" >> Gemfile
    echo "gem 'webpacker'" >> Gemfile
    cp ~/programming/Scripts/rails_new/tools/Procfile . ;;

  api)
    rails new $1 --database=mysql --skip-turbolinks --skip-test --api
    cd ./$1
    cp -f ~/programming/Scripts/rails_new/tools/Gemfile_api ./Gemfile ;;

  api-webpack)
    rails new $1 --database=mysql --skip-turbolinks --skip-test --api --webpack
    cd ./$1
    cp -f ~/programming/Scripts/rails_new/tools/Gemfile_api ./Gemfile
    echo "#webpack" >> Gemfile
    echo "gem 'webpacker'" >> Gemfile
    cp ~/programming/Scripts/rails_new/tools/Procfile . ;;

esac

bundle install --path vendor/bundler --jobs=4
bundle update

for option in $*; do
  case $option in

    --docker)
      tmp = docker-compose run web
      cp ~/programming/Scripts/rails_new/tools/Dockerfile .
      cp ~/programming/Scripts/rails_new/tools/docker-compose.yml .
      cp -r ~/programming/Scripts/rails_new/tools/scripts .
      docker-compose build
      docker-compose up -d ;;

    --react)
      $tmp npm install --save redux
      $tmp npm install --save react-redux
      $tmp npm install --save redux-thunk
      $tmp npm install --save-dev redux-devtools
      $tmp npm install --save material-ui
      $tmp npm install --save react-router-dom
      $tmp npm install --save react-tap-event-plugin
      $tmp npm install --save superagent
      $tmp rails webpacker:install:react
      mkdir ./app/javascript/packs/actions
      mkdir ./app/javascript/packs/components
      mkdir ./app/javascript/packs/constants
      mkdir ./app/javascript/packs/reducers
      mkdir ./app/javascript/packs/containers
      rm -f ./app/javascript/packs/application.js ;;

  esac
done

case $2 in
  normal)         $tmp rails haml:replace_erbs ;;
  normal-webpack) $tmp rails haml:replace_erbs ;;
esac

$tmp rails db:create db:migrate
$tmp rails g rspec:install
cp -rf ~/programming/Scripts/rails_new/tools/locales ./config
cp -rf ~/programming/Scripts/rails_new/tools/spec .
cp ~/programming/Scripts/rails_new/tools/.rspec  .
cp ~/programming/Scripts/rails_new/tools/.rubocop.yml .
touch .env.sample
touch .env
