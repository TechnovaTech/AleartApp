module.exports = {
  apps: [{
    name: 'alert-app',
    script: 'npm',
    args: 'start',
    cwd: '/var/www/alert-app/alert_admin',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 9999,
      MONGODB_URI: 'mongodb://vivekvora:Technova%40990@72.60.30.153:27017/aleartapp?authSource=admin',
      EMAIL_USER: 'hello.technovatechnologies@gmail.com',
      EMAIL_PASS: 'oavumbyivkfwdptp',
      NODE_TLS_REJECT_UNAUTHORIZED: '0'
    }
  }]
};