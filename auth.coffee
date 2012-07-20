everyauth = require "everyauth"

merge_facebook_user_data = (user, ext_user) ->
  user.name ?= ext_user.name
  user.link ?= ext_user.link
  user.email ?= ext_user.email
  user.facebook_id ?= ext_user.id

merge_twitter_user_data = (user, ext_user) ->
  user.name ?= ext_user.name || ext_user.screen_name
  user.link ?= "https://twitter.com/#{ext_user.screen_name}"
  user.twitter_id ?= ext_user.id

merge_google_user_data = (user, ext_user) ->
  user.name ?= ext_user.name || ext_user.given_name
  user.link ?= ext_user.link
  user.google_id ?= ext_user.id

merge_linkedin_user_data = (user, ext_user) ->
  user.name ?= "#{ext_user.firstName} #{ext_user.lastName}"
  user.link = ext_user.publicProfileUrl
  user.linkedin_id ?= ext_user.id

merge_github_user_data = (user, ext_user) ->
  user.link ?= ext_user.html_url
  user.email ?= ext_user.email
  user.github_id ?= ext_user.login

merge_foursquare_user_data = (user, ext_user) ->
  user.name ?= "#{ext_user.firstName} #{ext_user.lastName}"
  user.email ?= ext_user.contact.email
  user.foursquare_id ?= ext_user.id

create_or_update_user = (db, session, user_data, merge_function, promise) ->
  save = (user) ->
    db.createVertex user, (err, user) ->
      db.loadRecord "#6:0", (err, root) ->
        db.createEdge root, user, { label: "user" }, (err) ->
          return promise.fail(err) if err?
          promise.fulfill
            id: user["@rid"]

  save_callback = (err, user) ->
    return promise.fail(err) if err?
    promise.fulfill
      id: user["@rid"]

  if session.auth? and session.auth.userId?
    db.loadRecord session.auth.userId, (err, user) ->
      return promise.fail(err) if err?
      merge_function user, user_data
      db.save user, save_callback
  else
    user =
      _type: "user"
    merge_function user, user_data
    db.createVertex user, (err, user) ->
      db.loadRecord "#6:0", (err, root) ->
        db.createEdge root, user, { label: "user" }, (err) ->
          save_callback(err, user)

find_or_create_user = (db, query_tmpl, merge_function) ->
  return (session, accessToken, accessTokenExtra, user_data) ->
    promise = @Promise()

    db.command "#{query_tmpl}'#{user_data.id}'", (err, results) ->
      return promise.fail(err) if err?

      create_or_update_user db, session, user_data, merge_function, promise
    return promise

facebook_init = (config, db) ->
  everyauth.facebook.configure
    appId: config.auth.facebook.app_id
    appSecret: config.auth.facebook.app_secret
    scope: "email"
    myHostname: config.hostname
    findOrCreateUser: find_or_create_user(db, "SELECT @rid FROM V where _type = 'user' and facebook_id = ", merge_facebook_user_data)
    redirectPath: "/r/back_to_referer"

twitter_init = (config, db) ->
  everyauth.twitter.configure
    consumerKey: config.auth.twitter.consumer_key
    consumerSecret: config.auth.twitter.consumer_secret
    myHostname: config.hostname
    findOrCreateUser: find_or_create_user(db, "SELECT @rid FROM V where _type = 'user' and twitter_id = ", merge_twitter_user_data)
    redirectPath: "/r/back_to_referer"

google_init = (config, db) ->
  everyauth.google.configure
    appId: config.auth.google.app_id
    appSecret: config.auth.google.app_secret
    scope: "https://www.googleapis.com/auth/userinfo.profile"
    myHostname: config.hostname
    findOrCreateUser: find_or_create_user(db, "SELECT @rid FROM V where _type = 'user' and google_id = ", merge_google_user_data)
    redirectPath: "/r/back_to_referer"

linkedin_init = (config, db) ->
  everyauth.linkedin.configure
    consumerKey: config.auth.linkedin.consumer_key
    consumerSecret: config.auth.linkedin.consumer_secret
    myHostname: config.hostname
    findOrCreateUser: find_or_create_user(db, "SELECT @rid FROM V where _type = 'user' and linkedin_id = ", merge_linkedin_user_data)
    redirectPath: "/r/back_to_referer"

github_init = (config, db) ->
  everyauth.github.configure
    appId: config.auth.github.app_id
    appSecret: config.auth.github.app_secret
    myHostname: config.hostname
    findOrCreateUser: find_or_create_user(db, "SELECT @rid FROM V where _type = 'user' and github_id = ", merge_github_user_data)
    callbackPath: "/auth/github/callback"
    redirectPath: "/r/back_to_referer"

foursquare_init = (config, db) ->
  everyauth.foursquare.configure
    appId: config.auth.foursquare.app_id
    appSecret: config.auth.foursquare.app_secret
    myHostname: config.hostname
    findOrCreateUser: find_or_create_user(db, "SELECT @rid FROM V where _type = 'user' and foursquare_id = ", merge_foursquare_user_data)
    redirectPath: "/r/back_to_referer"

exports.init = (config, db) ->
  everyauth.everymodule.findUserById (userId, callback) ->
    db.loadRecord userId, callback

  facebook_init config, db
  twitter_init config, db
  google_init config, db
  linkedin_init config, db
  github_init config, db
  foursquare_init config, db

  return everyauth

exports.expose_user = (req, res, next) ->
  if req.user?
    res.locals.user = req.user
  next()