const mongoose = require('mongoose')
const bcrypt = require('bcryptjs')

const UserSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  name: { type: String, default: '' },
  isActive: { type: Boolean, default: true },
  subscription: { type: String, enum: ['free', 'premium'], default: 'free' },
  role: { type: String, enum: ['user', 'admin'], default: 'user' },
  createdAt: { type: Date, default: Date.now },
  lastLogin: { type: Date, default: Date.now }
})

const User = mongoose.model('User', UserSchema)

async function seedAdmin() {
  try {
    await mongoose.connect('mongodb://localhost:27017/aleartapp')
    
    const existingAdmin = await User.findOne({ email: 'admin@gmail.com' })
    
    if (!existingAdmin) {
      const hashedPassword = await bcrypt.hash('admin123', 12)
      
      const admin = new User({
        username: 'admin',
        email: 'admin@gmail.com',
        password: hashedPassword,
        name: 'Administrator',
        role: 'admin'
      })
      
      await admin.save()
      console.log('Admin user created successfully')
    } else {
      console.log('Admin user already exists')
    }
    
    await mongoose.disconnect()
  } catch (error) {
    console.error('Error seeding admin:', error)
  }
}

seedAdmin()