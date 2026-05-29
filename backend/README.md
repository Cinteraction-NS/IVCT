# Cinteraction API

## Installation

```
git clone git@github.com:nswebdevelopment/Cinteraction_API.git
cd Cinteraction_API
```

Install all the dependencies using composer
```
composer install
```

Copy the example env file and make the required configuration changes in the .env file
```
cp .env.example .env
```

Change the values of the `.env` file as necessary.

Generate a new application key
```
php artisan key:generate
```

Run the database migrations (Set the database connection in .env before migrating)
```
php artisan migrate
```

## Static analysis

```
.\vendor\bin\phpstan analyse
```

## Testing

```
.\vendor\bin\pest
```