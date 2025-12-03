const mongoose = require('mongoose');

// Plan Schema
const PlanSchema = new mongoose.Schema({
  name: { type: String, required: true },
  price: { type: Number, required: true },
  duration: { type: String, enum: ['monthly', 'yearly'], default: 'monthly' },
  features: [String],
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now }
});

const Plan = mongoose.models.Plan || mongoose.model('Plan', PlanSchema);

async function seedPlans() {
  try {
    // Connect to MongoDB
    await mongoose.connect('mongodb://vivekvora:Technova%40990@72.60.30.153:27017/aleartapp?authSource=admin');
    
    // Clear existing plans
    await Plan.deleteMany({});
    
    // Create new plans
    const plans = [
      {
        name: 'Basic Plan',
        price: 99,
        duration: 'monthly',
        features: [
          'SMS payment monitoring',
          'Basic analytics',
          'Email support',
          'Up to 100 transactions/month'
        ],
        isActive: true
      },
      {
        name: 'Premium Plan',
        price: 199,
        duration: 'monthly',
        features: [
          'Unlimited SMS monitoring',
          'Advanced analytics',
          'PDF reports',
          'Priority support',
          'Real-time notifications',
          'QR code generation'
        ],
        isActive: true
      },
      {
        name: 'Pro Plan',
        price: 299,
        duration: 'monthly',
        features: [
          'Everything in Premium',
          'API access',
          'Custom integrations',
          '24/7 phone support',
          'White-label solution',
          'Multi-user access'
        ],
        isActive: true
      }
    ];
    
    await Plan.insertMany(plans);
    console.log('Plans seeded successfully!');
    
    // Verify plans
    const savedPlans = await Plan.find({});
    console.log('Saved plans:', savedPlans);
    
  } catch (error) {
    console.error('Error seeding plans:', error);
  } finally {
    await mongoose.disconnect();
  }
}

seedPlans();