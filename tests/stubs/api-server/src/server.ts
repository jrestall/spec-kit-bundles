type OrderRequest = {
  cartId: string;
};

export function createOrder(request: OrderRequest) {
  return {
    orderId: `order-${request.cartId}`,
    status: "accepted"
  };
}
