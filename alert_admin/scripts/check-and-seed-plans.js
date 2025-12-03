const mongoose = require('mongoose');

// MongoDB connection
const MONGODB_URI = 'mongodb://vivekvora:Technova%40990@72.60.30.153:27017/aleartapp?authSource=admin';

const PlanSchema = new mongoose.Schema({
  name: String,
  price: Number,
  duration: String,
  features: [String],
  isActive: Boolean,
  createdAt: Date,
  updatedAt: Date
});

const Plan = mongoose.model('Plan', PlanSchema);

async function checkAndSeedPlans() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Check existing plans
    const existingPlans = await Plan.find({});
    console.log(`📊 Found ${existingPlans.length} existing plans`);

    if (existingPlans.length > 0) {
      console.log('📋 Existing plans:');
      existingPlans.forEach(plan => {
        console.log(`- ${plan.name}: ₹${plan.price}/${plan.duration}`);
      });
      console.log('\n✅ Plans already exist! No need to seed.');
      return;
    }

    // Create default plans if none exist
    console.log('🌱 No plans found. Creating default plans...');
    
    const plans = [
      {
        name: 'Premium Plan',
        price: 299,
        duration: 'monthly',
        features: [
          'Unlimited SMS monitoring',
          'Real-time notifications',
          'PDF report generation',
          'Multi-language support',
          'Priority customer support',
          'Advanced analytics',
          'QR code management'
        ],
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Annual Premium',
        price: 2999,
        duration: 'yearly',
        features: [
          'All Premium features',
          'Unlimited SMS monitoring',
          'Real-time notifications',
          'PDF report generation',
          'Multi-language support',
          'Priority customer support',
          'Advanced analytics',
          'QR code management',
          '2 months free (Save ₹599)'
        ],
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];

    await Plan.insertMany(plans);
    console.log('✅ Default plans created successfully!');
    console.log('📋 Created plans:');
    plans.forEach(plan => {
      console.log(`- ${plan.name}: ₹${plan.price}/${plan.duration}`);
    });

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

checkAndSeedPlans();