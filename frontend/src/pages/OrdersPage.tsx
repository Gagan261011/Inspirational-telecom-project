import { useState, useEffect } from "react"
import { Link } from "react-router-dom"
import { motion } from "framer-motion"
import { Package, Eye, Calendar, DollarSign, Clock } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Spinner } from "@/components/ui/spinner"
import { useStore } from "@/store"
import { orderApi, Order } from "@/lib/api"
import { useToast } from "@/hooks/use-toast"

const statusColors: Record<string, "default" | "secondary" | "success" | "warning" | "destructive"> = {
  PENDING: "warning",
  CONFIRMED: "info" as any,
  SHIPPED: "secondary",
  DELIVERED: "success",
  CANCELLED: "destructive",
}

export function OrdersPage() {
  const { toast } = useToast()
  const { user } = useStore()
  
  const [orders, setOrders] = useState<Order[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    if (user) {
      loadOrders()
    }
  }, [user])

  const loadOrders = async () => {
    if (!user) return
    
    try {
      setIsLoading(true)
      const data = await orderApi.getOrders(user.id)
      setOrders(data)
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to load orders",
        variant: "destructive",
      })
    } finally {
      setIsLoading(false)
    }
  }

  if (!user) {
    return (
      <div className="container py-16 text-center">
        <p className="text-muted-foreground mb-4">Please sign in to view your orders.</p>
        <Link to="/login">
          <Button variant="gradient">Sign In</Button>
        </Link>
      </div>
    )
  }

  if (isLoading) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center">
        <Spinner size="lg" />
      </div>
    )
  }

  if (orders.length === 0) {
    return (
      <div className="container py-16">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="max-w-md mx-auto text-center"
        >
          <div className="w-24 h-24 mx-auto mb-6 rounded-full bg-muted flex items-center justify-center">
            <Package className="h-12 w-12 text-muted-foreground" />
          </div>
          <h1 className="text-2xl font-bold mb-2">No orders yet</h1>
          <p className="text-muted-foreground mb-6">
            Start shopping to see your orders here.
          </p>
          <Link to="/products">
            <Button variant="gradient">Browse Products</Button>
          </Link>
        </motion.div>
      </div>
    )
  }

  return (
    <div className="container py-8">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-8"
      >
        <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
          My{" "}
          <span className="bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
            Orders
          </span>
        </h1>
        <p className="mt-2 text-muted-foreground">
          Track and manage your orders
        </p>
      </motion.div>

      <div className="space-y-4">
        {orders.map((order, index) => (
          <motion.div
            key={order.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
          >
            <Card className="overflow-hidden hover:shadow-lg transition-shadow">
              <CardHeader className="bg-muted/50">
                <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                  <div className="flex items-center gap-4">
                    <div className="w-12 h-12 rounded-lg bg-gradient-to-br from-purple-600 to-pink-600 flex items-center justify-center">
                      <Package className="h-6 w-6 text-white" />
                    </div>
                    <div>
                      <CardTitle className="text-lg">Order #{order.id}</CardTitle>
                      <div className="flex items-center gap-2 text-sm text-muted-foreground">
                        <Calendar className="h-4 w-4" />
                        {new Date(order.createdAt).toLocaleDateString()}
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center gap-4">
                    <Badge variant={statusColors[order.status] || "default"}>
                      {order.status}
                    </Badge>
                    <Link to={`/orders/${order.id}`}>
                      <Button variant="outline" size="sm">
                        <Eye className="h-4 w-4 mr-2" />
                        View Details
                      </Button>
                    </Link>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="p-4">
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <div>
                    <p className="text-sm text-muted-foreground">Items</p>
                    <p className="font-medium">{order.items?.length || 0} products</p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Total</p>
                    <p className="font-medium flex items-center gap-1">
                      <DollarSign className="h-4 w-4" />
                      {order.totalAmount.toFixed(2)}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Shipping</p>
                    <p className="font-medium">{order.shippingAddress || "Digital Delivery"}</p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Est. Delivery</p>
                    <p className="font-medium flex items-center gap-1">
                      <Clock className="h-4 w-4" />
                      {order.status === "DELIVERED" 
                        ? "Delivered" 
                        : new Date(Date.now() + 5 * 24 * 60 * 60 * 1000).toLocaleDateString()
                      }
                    </p>
                  </div>
                </div>

                {/* Order Items Preview */}
                {order.items && order.items.length > 0 && (
                  <div className="mt-4 pt-4 border-t">
                    <div className="flex gap-2 overflow-x-auto">
                      {order.items.slice(0, 5).map((item, i) => (
                        <div
                          key={i}
                          className="w-16 h-16 flex-shrink-0 rounded-lg bg-muted flex items-center justify-center"
                        >
                          <span className="text-2xl">📦</span>
                        </div>
                      ))}
                      {order.items.length > 5 && (
                        <div className="w-16 h-16 flex-shrink-0 rounded-lg bg-muted flex items-center justify-center">
                          <span className="text-sm text-muted-foreground">
                            +{order.items.length - 5}
                          </span>
                        </div>
                      )}
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          </motion.div>
        ))}
      </div>
    </div>
  )
}
