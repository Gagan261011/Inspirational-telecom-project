const API_USER_BASE = 'http://localhost:8081/api/v1'
const API_ORDER_BASE = 'http://localhost:8082/api/v1'

async function fetchAPI(url: string, options?: RequestInit) {
  const response = await fetch(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
  })
  
  if (!response.ok) {
    const error = await response.json().catch(() => ({ message: 'Request failed' }))
    throw new Error(error.message || 'Request failed')
  }
  
  return response.json()
}

// Auth API
export const authAPI = {
  login: (email: string, password: string) =>
    fetchAPI(`${API_USER_BASE}/auth/login`, {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    }),
  
  register: (data: { email: string; password: string; firstName: string; lastName: string; phone?: string }) =>
    fetchAPI(`${API_USER_BASE}/auth/register`, {
      method: 'POST',
      body: JSON.stringify(data),
    }),
}

// User API
export const userAPI = {
  getProfile: (userId: number) =>
    fetchAPI(`${API_USER_BASE}/users/${userId}/profile`),
  
  updateProfile: (userId: number, data: any) =>
    fetchAPI(`${API_USER_BASE}/users/${userId}/profile`, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),
  
  getBillingHistory: (userId: number) =>
    fetchAPI(`${API_USER_BASE}/users/${userId}/billing`),
  
  payBill: (recordId: number, paymentMethod: string) =>
    fetchAPI(`${API_USER_BASE}/billing/${recordId}/pay?paymentMethod=${encodeURIComponent(paymentMethod)}`, {
      method: 'POST',
    }),
}

// Product API
export const productAPI = {
  getAll: () => fetchAPI(`${API_ORDER_BASE}/products`),
  
  getById: (id: number) => fetchAPI(`${API_ORDER_BASE}/products/${id}`),
  
  getByCategory: (category: string) =>
    fetchAPI(`${API_ORDER_BASE}/products/category/${encodeURIComponent(category)}`),
  
  getFeatured: () => fetchAPI(`${API_ORDER_BASE}/products/featured`),
  
  search: (query: string) =>
    fetchAPI(`${API_ORDER_BASE}/products/search?query=${encodeURIComponent(query)}`),
  
  getCategories: () => fetchAPI(`${API_ORDER_BASE}/categories`),
}

// Cart API
export const cartAPI = {
  get: (userId: number) => fetchAPI(`${API_ORDER_BASE}/cart/${userId}`),
  
  addItem: (userId: number, productId: number, quantity: number = 1) =>
    fetchAPI(`${API_ORDER_BASE}/cart/${userId}/items?productId=${productId}&quantity=${quantity}`, {
      method: 'POST',
    }),
  
  updateItem: (userId: number, itemId: number, quantity: number) =>
    fetchAPI(`${API_ORDER_BASE}/cart/${userId}/items/${itemId}?quantity=${quantity}`, {
      method: 'PUT',
    }),
  
  removeItem: (userId: number, itemId: number) =>
    fetchAPI(`${API_ORDER_BASE}/cart/${userId}/items/${itemId}`, {
      method: 'DELETE',
    }),
  
  clear: (userId: number) =>
    fetchAPI(`${API_ORDER_BASE}/cart/${userId}`, {
      method: 'DELETE',
    }),
}

// Order API
export const orderAPI = {
  create: (data: any) =>
    fetchAPI(`${API_ORDER_BASE}/orders`, {
      method: 'POST',
      body: JSON.stringify(data),
    }),
  
  getById: (orderId: number) => fetchAPI(`${API_ORDER_BASE}/orders/${orderId}`),
  
  getByNumber: (orderNumber: string) =>
    fetchAPI(`${API_ORDER_BASE}/orders/number/${orderNumber}`),
  
  getUserOrders: (userId: number) => fetchAPI(`${API_ORDER_BASE}/orders/user/${userId}`),
  
  track: (trackingNumber: string) =>
    fetchAPI(`${API_ORDER_BASE}/orders/track/${trackingNumber}`),
  
  processPayment: (data: any) =>
    fetchAPI(`${API_ORDER_BASE}/payments`, {
      method: 'POST',
      body: JSON.stringify(data),
    }),
}
