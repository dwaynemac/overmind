# configuration example
PADMA_DEPLOYMENT = {
  staging: {
    server: :heroku,
    remote_name: :staging,
    force_push: false
  },
  production: {
    server: :heroku,
    remote_name: :production,
    force_push: false
  }
}
