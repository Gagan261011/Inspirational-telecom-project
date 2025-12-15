import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { Layout } from '@/components/layout'
import {
  HomePage,
  LoginPage,
  RegisterPage,
  ProductsPage,
  CartPage,
  CheckoutPage,
  OrdersPage,
  OrderTrackingPage,
  ProfilePage,
  BillingPage,
} from '@/pages'

function App() {
  return (
    <Router>
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<HomePage />} />
          <Route path="/products" element={<ProductsPage />} />
          <Route path="/products/:category" element={<ProductsPage />} />
          <Route path="/cart" element={<CartPage />} />
          <Route path="/checkout" element={<CheckoutPage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />
          <Route path="/profile" element={<ProfilePage />} />
          <Route path="/orders" element={<OrdersPage />} />
          <Route path="/orders/:id" element={<OrderTrackingPage />} />
          <Route path="/billing" element={<BillingPage />} />
        </Route>
      </Routes>
    </Router>
  )
}

export default App
