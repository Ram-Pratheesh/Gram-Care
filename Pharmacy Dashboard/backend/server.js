const express = require('express');
const cors = require('cors');
const { MongoClient } = require('mongodb');
const dotenv = require('dotenv');
const bcrypt = require('bcrypt');

dotenv.config();

const app = express();
const PORT = 4000;

app.use(cors());
app.use(express.json());

// MongoDB setup
//const client = new MongoClient("mongodb+srv://ajayrsrinivas:6220@cluster0.hhfc8.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0");
const client = new MongoClient("mongodb+srv://anirudhchandrasekaran_db_user:thbDXCQPgiUayhZa@gramcare.wgfq5mx.mongodb.net/?retryWrites=true&w=majority&appName=GramCare");

let usersCollection;
let inventoryCollection;

async function connectDB() {
  try {
    await client.connect();
    const db = client.db('gramcare');   // ✅ keep consistent
    usersCollection = db.collection('pharmacies');
    inventoryCollection = db.collection('pharm_inventory');
    console.log('MongoDB connected');
  } catch (err) {
    console.error(err);
  }
}
connectDB();

// ================= AUTH ==================
// Signup
app.post('/api/signup', async (req, res) => {
  const { username, pharmacyName, address, contactNumber, email, password } = req.body;

  if (!username || !pharmacyName || !address || !contactNumber || !email || !password) {
    return res.status(400).json({ message: 'All fields are required.' });
  }

  const existingUser = await usersCollection.findOne({ email });
  if (existingUser) {
    return res.status(400).json({ message: 'Email already registered.' });
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  await usersCollection.insertOne({
    username,
    pharmacyName,
    address,
    contactNumber,
    email,
    password: hashedPassword
  });

  res.status(201).json({ message: 'Pharmacy registered successfully!' });
});

// Login
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'All fields are required.' });
  }

  const user = await usersCollection.findOne({ email });
  if (!user) return res.status(400).json({ message: 'User not found.' });

  const match = await bcrypt.compare(password, user.password);
  if (!match) return res.status(400).json({ message: 'Invalid password.' });

  res.status(200).json({
    message: 'Login successful!',
    email: user.email,
    pharmacyName: user.pharmacyName,
    address: user.address,
    contactNumber: user.contactNumber
  });
});

// Profile
app.get('/api/profile', async (req, res) => {
  const email = req.query.email;
  if (!email) return res.status(400).json({ message: 'Email is required' });

  const user = await usersCollection.findOne({ email }, { projection: { password: 0 } });
  if (!user) return res.status(404).json({ message: 'User not found' });

  res.status(200).json(user);
});

// ================= INVENTORY ==================

// Add stock
app.post('/api/inventory', async (req, res) => {
  const { email, itemName, category, quantity, restockDate } = req.body;
  if (!email || !itemName || !category || !quantity || !restockDate) {
    return res.status(400).json({ message: "All fields are required" });
  }

  await inventoryCollection.insertOne({ email, itemName, category, quantity, restockDate });
  res.status(201).json({ message: "Stock added successfully" });
});

// Add stock (updated)
// app.post('/api/inventory', async (req, res) => {
//   const { email, itemName, category, quantity, restockDate } = req.body;

//   if (!email || !itemName || !category || !quantity || !restockDate) {
//     return res.status(400).json({ message: "All fields are required" });
//   }

//   try {
//     // Find the pharmacy details
//     const pharmacy = await usersCollection.findOne({ email });
//     if (!pharmacy) {
//       return res.status(404).json({ message: "Pharmacy not found" });
//     }

//     // Insert stock with pharmacy info embedded
//     await inventoryCollection.insertOne({
//       email,
//       itemName,
//       category,
//       quantity,
//       restockDate,
//       pharmacyName: pharmacy.pharmacyName,
//       address: pharmacy.address,
//       contactNumber: pharmacy.contactNumber
//     });

//     res.status(201).json({ message: "Stock added successfully" });
//   } catch (err) {
//     console.error("Error adding stock:", err);
//     res.status(500).json({ message: "Server error" });
//   }
// });


// Fetch stock
app.get('/api/inventory', async (req, res) => {
  const email = req.query.email;
  if (!email) return res.status(400).json({ message: "Email required" });

  const items = await inventoryCollection.find({ email }).toArray();
  res.status(200).json(items);
});

app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
