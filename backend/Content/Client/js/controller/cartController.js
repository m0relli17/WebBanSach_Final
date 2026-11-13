var cart = {
    init: function () {
        cart.regEvents();
    },
    formatVND: function (num) {
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + " VND";
    },
    updateRowAndTotal: function (rowInput) {
        var $input = $(rowInput);
        var qty = parseInt($input.val(), 10);
        if (isNaN(qty) || qty < 1) {
            qty = 1;
            $input.val(1);
        } else if (qty > 999) {
            qty = 999;
            $input.val(999);
        }
        var price = parseFloat($input.data('price')) || 0;
        var subtotal = qty * price;

        // Cập nhật thành tiền ngay lập tức trên giao diện dòng này
        $input.closest('.cart-item-row').find('.item-subtotal').text(cart.formatVND(subtotal));

        // Tính lại tổng cộng toàn bộ giỏ hàng ngay lập tức
        var total = 0;
        $('.cart-item-row').each(function () {
            var itemQty = parseInt($(this).find('.txtQuantity').val(), 10) || 0;
            var itemPrice = parseFloat($(this).data('price')) || 0;
            total += itemQty * itemPrice;
        });

        // Cập nhật tổng tiền ngay tức thì
        $('#cart-total-amount').text(cart.formatVND(total));

        // Đồng bộ ngầm lên server sau 300ms
        cart.debouncedServerSync();
    },
    syncTimer: null,
    debouncedServerSync: function () {
        clearTimeout(cart.syncTimer);
        cart.syncTimer = setTimeout(function () {
            var cartList = [];
            $('.txtQuantity').each(function () {
                cartList.push({
                    Quantity: parseInt($(this).val(), 10) || 1,
                    sach: {
                        MaSach: $(this).data('id')
                    }
                });
            });

            if (cartList.length === 0) return;

            $.ajax({
                url: '/Cart/Update',
                type: 'POST',
                data: { cartModel: JSON.stringify(cartList) },
                dataType: 'json',
                success: function (res) {
                    if (res && res.status && res.totalFormatted) {
                        $('#cart-total-amount').text(res.totalFormatted);
                    }
                }
            });
        }, 300);
    },
    regEvents: function () {
        // Tự động tính lại khi người dùng gõ hoặc thay đổi số lượng
        $(document).on('input change', '.txtQuantity', function () {
            cart.updateRowAndTotal(this);
        });

        // Bấm nút tăng số lượng (+)
        $(document).on('click', '.btn-qty-plus', function () {
            var $input = $(this).closest('.input-group').find('.txtQuantity');
            var val = parseInt($input.val(), 10) || 1;
            if (val < 999) {
                $input.val(val + 1);
                cart.updateRowAndTotal($input);
            }
        });

        // Bấm nút giảm số lượng (-)
        $(document).on('click', '.btn-qty-minus', function () {
            var $input = $(this).closest('.input-group').find('.txtQuantity');
            var val = parseInt($input.val(), 10) || 1;
            if (val > 1) {
                $input.val(val - 1);
                cart.updateRowAndTotal($input);
            }
        });

        // Xóa một sản phẩm
        $(document).on('click', '.btn-delete-item', function () {
            var $row = $(this).closest('.cart-item-row');
            var id = $(this).data('id');

            if (!confirm('Bạn có chắc chắn muốn xóa cuốn sách này khỏi giỏ hàng?')) {
                return;
            }

            $.ajax({
                url: '/Cart/Delete',
                type: 'POST',
                data: { id: id },
                dataType: 'json',
                success: function (res) {
                    if (res.status == true) {
                        if (res.isEmpty) {
                            window.location.reload();
                        } else {
                            $row.fadeOut(250, function () {
                                $(this).remove();
                                if (res.totalFormatted) {
                                    $('#cart-total-amount').text(res.totalFormatted);
                                }
                                $('#cart-item-count').text($('.cart-item-row').length);
                            });
                        }
                    }
                }
            });
        });

        // Xóa tất cả sản phẩm
        $('#btnDeleteAll').off('click').on('click', function () {
            if (!confirm('Bạn có chắc chắn muốn xóa tất cả sản phẩm trong giỏ hàng?')) {
                return;
            }
            $.ajax({
                url: '/Cart/DeleteAll',
                type: 'POST',
                dataType: 'json',
                success: function (res) {
                    if (res.status == true) {
                        window.location.reload();
                    }
                }
            });
        });
    }
};

$(document).ready(function () {
    cart.init();
});
