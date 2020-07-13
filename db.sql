-- schema
  drop schema if exists api cascade;
  create schema api;

  create table api.todos (
    id serial primary key,
    done boolean not null default false,
    task text not null,
    due timestamptz
  );

-- data
  insert into api.todos (id, task)
  SELECT generate_series(1,${aTodosCount}) AS int, md5(random()::text) AS task;

-- auth
  drop role if exists web_anon;
  create role web_anon nologin;

  grant usage on schema api to web_anon;
  grant select on api.todos to web_anon;

  drop role if exists authenticator;
  create role authenticator noinherit login password 'test';
  grant web_anon to authenticator;