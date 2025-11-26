const mongoose = require('mongoose')
const bcrypt = require('bcryptjs')

async function createAdmin() {
  try {
    const mongoUri = 'mongodb://vivekvora:Technova%40990@72.60.30.153:27017/aleartapp?authSource=admin'
    await mongoose.connect(mongoUri)
    
    // Use the exact same schema as the User model
    const UserSchema = new mongoose.Schema({
      username: { type: String, required: true, unique: true },
      email: { type: String, required: true, unique: true },
      mobile: { type: String, required: true },
      password: { type: String, required: true },
      isActive: { type: Boolean, default: true },
      subscription: { type: String, enum: ['free', 'premium'], default: 'free' },
      role: { type: String, enum: ['user', 'admin'], default: 'user' },
      createdAt: { type: Date, default: Date.now },
      lastLogin: { type: Date, default: Date.now }
    })
    
    const User = mongoose.model('User', UserSchema)
    
    // Delete existing admin if exists
    await User.deleteOne({ email: 'admin@gmail.com' })
    console.log('Deleted existing admin user (if any)')
    
    // Create new admin user
    const hashedPassword = await bcrypt.hash('admin123', 12)
    
    const admin = new User({
      username: 'admin',
      email: 'admin@gmail.com',
      mobile: '1234567890',
      password: hashedPassword,
      isActive: true,
      role: 'admin',
      subscription: 'premium'
    })
    
    await admin.save()
    console.log('✅ Admin user created successfully!')
    console.log('📧 Email: admin@gmail.com')
    console.log('🔑 Password: admin123')
    console.log('👤 Role: admin')
    console.log('📱 Mobile: 1234567890')
    
    // Verify the user was created
    const createdUser = await User.findOne({ email: 'admin@gmail.com' })
    if (createdUser) {
      console.log('✅ Verification: Admin user exists in database')
      console.log('🔐 Password hash:', createdUser.password.substring(0, 20) + '...')
    }
    
    await mongoose.disconnect()
  } catch (error) {
    console.error('❌ Error creating admin:', error)
  }
}

createAdmin()