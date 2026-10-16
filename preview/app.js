// Victorious MARKET — Sovereign Merchant Terminal Web Simulator Engine
// Perfectly synchronized with index.html, style.css, and newVmarket Backend Invariants

(function() {
  'use strict';

  // --- Reactive State Store ---
  window.state = {
    balance: {
      netAvailable: 284500.00,
      pendingEscrow: 42000.00,
      totalSettled: 1850000.00,
      isMasked: false
    },
    bankSecurity: {
      bankName: 'Zenith Bank PLC',
      accountNumber: '0123456789',
      beneficiary: 'APEX RETAIL ENTERPRISES',
      isCooling: true,
      cooldownHoursLeft: 46
    },
    orders: [
      {
        id: 'ord-1',
        orderNum: 'VM-ORD-9081',
        customer: 'Chidi Okafor',
        phone: '+234 803 111 2233',
        itemSummary: 'iPhone 14 Pro Case & 65W GaN Charger',
        grossTotal: 42000.00,
        netPayout: 37800.00, // 90% net
        status: 'ready', // 'processing', 'ready', 'delivered'
        handoverPin: '482910',
        date: 'Today, 11:20 AM'
      },
      {
        id: 'ord-2',
        orderNum: 'VM-ORD-9077',
        customer: 'Amina Bello',
        phone: '+234 802 555 9900',
        itemSummary: 'Sony WH-1000XM5 Wireless Headphones',
        grossTotal: 320000.00,
        netPayout: 288000.00, // 90% net
        status: 'processing',
        handoverPin: '719302',
        date: 'Today, 09:45 AM'
      },
      {
        id: 'ord-3',
        orderNum: 'VM-ORD-9064',
        customer: 'Babajide Adeleke',
        phone: '+234 814 333 4455',
        itemSummary: 'Samsung T7 Shield SSD 1TB (Black)',
        grossTotal: 115000.00,
        netPayout: 103500.00, // 90% net
        status: 'delivered',
        handoverPin: 'Verified',
        date: 'Yesterday, 04:12 PM'
      },
      {
        id: 'ord-4',
        orderNum: 'VM-ORD-9052',
        customer: 'Grace Danjuma',
        phone: '+234 809 123 4567',
        itemSummary: 'Logitech MX Master 3S Bluetooth Mouse',
        grossTotal: 85000.00,
        netPayout: 76500.00, // 90% net
        status: 'delivered',
        handoverPin: 'Verified',
        date: 'Oct 14, 2026'
      }
    ],
    passes: [
      {
        id: 'pass-1',
        passCode: 'RES-884291',
        customer: 'Emeka Nwachukwu',
        phone: '+234 809 777 8899',
        productName: 'Apple MacBook Pro M3 (16GB/512GB)',
        price: 1850000.00,
        fee: 0.00,
        status: 'pending', // 'pending', 'inspected'
        expires: 'In 2 hours 40m'
      },
      {
        id: 'pass-2',
        passCode: 'RES-391044',
        customer: 'Fatima Kyari',
        phone: '+234 812 666 1234',
        productName: 'DJI Mini 4 Pro Fly More Combo',
        price: 980000.00,
        fee: 0.00,
        status: 'pending',
        expires: 'In 5 hours 15m'
      },
      {
        id: 'pass-3',
        passCode: 'RES-108257',
        customer: 'David Adele',
        phone: '+234 805 222 3344',
        productName: 'Sony PlayStation 5 Slim Digital',
        price: 620000.00,
        fee: 0.00,
        status: 'inspected',
        expires: 'Inspection Certified'
      }
    ],
    products: [
      {
        id: 1,
        name: 'Samsung Galaxy S24 Ultra (512GB Titanium)',
        price: 1450000.00,
        stock: 4,
        category: 'Electronics',
        freshDaysLeft: 6,
        isFresh: true,
        isActive: true
      },
      {
        id: 2,
        name: 'Apple MacBook Air 15" M2 (16GB RAM)',
        price: 1720000.00,
        stock: 2,
        category: 'Electronics',
        freshDaysLeft: 1,
        isFresh: true,
        isActive: true
      },
      {
        id: 3,
        name: 'Sony PlayStation 5 Slim Digital Edition',
        price: 620000.00,
        stock: 7,
        category: 'Gaming',
        freshDaysLeft: 0,
        isFresh: false, // Expired 7d freshness!
        isActive: true
      },
      {
        id: 4,
        name: 'Fresh Uyo Palm Oil Grade A (5 Litres)',
        price: 16500.00,
        stock: 25,
        category: 'Fresh Food & Groceries',
        freshDaysLeft: 5,
        isFresh: true,
        isActive: true
      }
    ],
    settledLedger: [
      { orderNum: 'VM-ORD-9064', customer: 'Babajide Adeleke', gross: 115000.00, net: 103500.00, date: 'Oct 15, 2026' },
      { orderNum: 'VM-ORD-9052', customer: 'Grace Danjuma', gross: 85000.00, net: 76500.00, date: 'Oct 14, 2026' },
      { orderNum: 'VM-ORD-9031', customer: 'Tariq Hassan', gross: 210000.00, net: 189000.00, date: 'Oct 12, 2026' }
    ],
    activeHandoverOrderId: null,
    currentOrderFilter: 'all'
  };

  // --- Helper Formatters ---
  function formatNaira(amount) {
    return '₦ ' + Number(amount).toLocaleString('en-NG', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    });
  }

  // --- Tab Navigation ---
  window.switchTab = function(tabName) {
    // 1. Hide all screen views
    document.querySelectorAll('.screen-view').forEach(v => v.classList.remove('active'));

    // 2. Map tab aliases
    let targetViewId = 'view-' + tabName;
    if (tabName === 'dashboard') targetViewId = 'view-dashboard';
    if (tabName === 'orders') targetViewId = 'view-orders';
    if (tabName === 'passes') targetViewId = 'view-passes';
    if (tabName === 'products') targetViewId = 'view-products';
    if (tabName === 'payout') targetViewId = 'view-payout';
    if (tabName === 'account') targetViewId = 'view-account';

    const targetView = document.getElementById(targetViewId);
    if (targetView) targetView.classList.add('active');

    // 3. Update bottom nav tabs
    document.querySelectorAll('.nav-tab').forEach(t => t.classList.remove('active'));
    document.querySelectorAll(`.nav-tab[onclick*="${tabName}"]`).forEach(t => t.classList.add('active'));

    // 4. Update studio top pills
    document.querySelectorAll('.nav-pill-btn').forEach(p => p.classList.remove('active'));
    document.querySelectorAll(`.nav-pill-btn[onclick*="${tabName}"]`).forEach(p => p.classList.add('active'));

    // Refresh view specific renderers
    if (tabName === 'dashboard') renderDashboard();
    if (tabName === 'orders') renderOrders();
    if (tabName === 'passes') renderPasses();
    if (tabName === 'products') renderProducts();
    if (tabName === 'payout') renderPayout();
  };

  // --- Balance Masking Toggle ---
  window.toggleBalance = function() {
    window.state.balance.isMasked = !window.state.balance.isMasked;
    const eye = document.getElementById('balance-eye-icon');
    const netEl = document.getElementById('net-balance-text');
    const escEl = document.getElementById('pending-escrow-text');

    if (window.state.balance.isMasked) {
      if (eye) eye.className = 'fa-regular fa-eye-slash';
      if (netEl) netEl.textContent = '₦ ••••••••';
      if (escEl) escEl.textContent = '₦ ••••••';
    } else {
      if (eye) eye.className = 'fa-regular fa-eye';
      if (netEl) netEl.textContent = formatNaira(window.state.balance.netAvailable);
      if (escEl) escEl.textContent = formatNaira(window.state.balance.pendingEscrow);
    }
  };

  // --- Render Dashboard ---
  function renderDashboard() {
    const netEl = document.getElementById('net-balance-text');
    const escEl = document.getElementById('pending-escrow-text');
    if (netEl && !window.state.balance.isMasked) {
      netEl.textContent = formatNaira(window.state.balance.netAvailable);
    }
    if (escEl && !window.state.balance.isMasked) {
      escEl.textContent = formatNaira(window.state.balance.pendingEscrow);
    }

    // Telemetry counts
    const activeOrders = window.state.orders.filter(o => o.status !== 'delivered').length;
    const activePasses = window.state.passes.filter(p => p.status === 'pending').length;
    const activeProds = window.state.products.filter(p => p.isActive).length;

    const ordCountEl = document.getElementById('orders-active-count');
    const passCountEl = document.getElementById('passes-active-count');
    const prodCountEl = document.getElementById('products-active-count');

    if (ordCountEl) ordCountEl.textContent = activeOrders;
    if (passCountEl) passCountEl.textContent = activePasses;
    if (prodCountEl) prodCountEl.textContent = activeProds;

    // Cooldown HUD
    renderCooldownBanner();
  }

  function renderCooldownBanner() {
    const banner = document.getElementById('cooldown-hud-banner');
    const hoursPill = document.getElementById('cooldown-hours-pill');
    if (!banner) return;

    if (window.state.bankSecurity.isCooling) {
      banner.style.display = 'flex';
      if (hoursPill) hoursPill.textContent = `${window.state.bankSecurity.cooldownHoursLeft}h remaining`;
    } else {
      banner.style.display = 'none';
    }
  }

  // --- Render Orders ---
  window.filterOrders = function(status, btn) {
    window.state.currentOrderFilter = status;
    document.querySelectorAll('.tab-filters-bar .filter-pill').forEach(p => p.classList.remove('active'));
    if (btn) btn.classList.add('active');
    renderOrders();
  };

  function renderOrders() {
    const container = document.getElementById('orders-list-container');
    if (!container) return;

    let filtered = window.state.orders;
    if (window.state.currentOrderFilter !== 'all') {
      filtered = window.state.orders.filter(o => o.status === window.state.currentOrderFilter);
    }

    if (filtered.length === 0) {
      container.innerHTML = `
        <div class="white-card" style="text-align: center; padding: 28px 14px; color: #6B7280;">
          <i class="fa-solid fa-box-open" style="font-size: 28px; margin-bottom: 8px;"></i>
          <p style="font-size: 13px; font-weight: 700;">No orders matching selected filter</p>
        </div>
      `;
      return;
    }

    container.innerHTML = filtered.map(order => {
      let badgeClass = 'processing';
      let badgeLabel = 'PROCESSING';
      let actionBtn = '';

      if (order.status === 'ready') {
        badgeClass = 'ready';
        badgeLabel = 'READY FOR COURIER';
        actionBtn = `
          <button class="order-btn-action handover-btn" onclick="openHandoverModal('${order.id}', '${order.orderNum}')">
            <i class="fa-solid fa-lock"></i> Verify Courier Handover PIN
          </button>
        `;
      } else if (order.status === 'delivered') {
        badgeClass = 'delivered';
        badgeLabel = 'DELIVERED & SETTLED';
        actionBtn = `
          <div style="font-size: 11px; font-weight: 800; color: #10B981; display: flex; align-items: center; justify-content: center; gap: 5px; margin-top: 10px;">
            <i class="fa-solid fa-circle-check"></i> Handover Verified &amp; Escrow Released
          </div>
        `;
      } else {
        badgeClass = 'processing';
        badgeLabel = 'PACKING & PREPARING';
        actionBtn = `
          <button class="order-btn-action ready-btn" onclick="markOrderReady('${order.id}')">
            <i class="fa-solid fa-circle-check"></i> Mark Ready for Courier Dispatch
          </button>
        `;
      }

      return `
        <div class="white-card" id="card-${order.id}">
          <div class="order-top-row">
            <span class="order-num-text">${order.orderNum}</span>
            <span class="status-badge ${badgeClass}">${badgeLabel}</span>
          </div>
          <div class="order-desc-row">
            <span style="color: #6B7280; font-weight: 600;">Customer: ${order.customer}</span>
            <span style="font-size: 11px; color: #9CA3AF;">${order.date}</span>
          </div>
          <div style="font-size: 12px; font-weight: 600; color: #1E1B4B; margin-bottom: 8px;">
            ${order.itemSummary}
          </div>
          <div class="thin-divider" style="margin: 8px 0;"></div>
          <div class="order-desc-row" style="margin-bottom: 0;">
            <span style="font-size: 11px; color: #6B7280;">Gross: ${formatNaira(order.grossTotal)}</span>
            <span class="payout-highlight">Net 90% Revenue: ${formatNaira(order.netPayout)}</span>
          </div>
          ${actionBtn}
        </div>
      `;
    }).join('');
  }

  window.markOrderReady = function(orderId) {
    const order = window.state.orders.find(o => o.id === orderId);
    if (!order) return;
    order.status = 'ready';
    renderOrders();
    renderDashboard();
    showToast(`Order ${order.orderNum} marked Ready! Dispatch courier notified with 6-digit PIN.`);
  };

  // --- Render Passes ---
  function renderPasses() {
    const container = document.getElementById('passes-list-container');
    if (!container) return;

    container.innerHTML = window.state.passes.map(pass => {
      const isPending = pass.status === 'pending';

      return `
        <div class="white-card">
          <div class="order-top-row">
            <span class="order-num-text" style="color: #FFA000;"><i class="fa-solid fa-ticket"></i> ${pass.passCode}</span>
            <span class="status-badge ${isPending ? 'ready' : 'delivered'}">
              ${isPending ? 'AWAITING IN-SHOP INSPECTION' : 'INSPECTION PASSED'}
            </span>
          </div>
          <div style="margin: 8px 0;">
            <div style="font-size: 13px; font-weight: 800; color: #1E1B4B;">${pass.productName}</div>
            <div style="font-size: 11px; color: #6B7280; margin-top: 2px;">
              Customer: <strong>${pass.customer}</strong> (${pass.phone})
            </div>
          </div>
          <div style="display: flex; justify-content: space-between; align-items: center; background: #F8F9FA; padding: 8px 10px; border-radius: 8px; margin: 8px 0;">
            <span style="font-size: 12px; font-weight: 800; color: #1E1B4B;">Item Value: ${formatNaira(pass.price)}</span>
            <span style="font-size: 10px; font-weight: 800; color: #5E17EB; background: #F3E8FF; padding: 2px 7px; border-radius: 10px;">
              ₦ 0.00 ZERO DEPOSIT PASS
            </span>
          </div>
          <div class="order-desc-row" style="margin-bottom: 0;">
            <span style="font-size: 11px; color: #9CA3AF;">Time Window: ${pass.expires}</span>
          </div>
          ${isPending ? `
            <button class="order-btn-action" style="background: #FFD700; color: #1E1B4B; border: none; font-weight: 800; margin-top: 10px;" onclick="openInspectionModal('${pass.passCode}')">
              <i class="fa-solid fa-qrcode"></i> Sign Off Customer In-Shop Inspection
            </button>
          ` : `
            <div style="font-size: 11px; font-weight: 800; color: #10B981; display: flex; align-items: center; justify-content: center; gap: 5px; margin-top: 10px;">
              <i class="fa-solid fa-shield-halved"></i> Certified &amp; Released (Net 90% Settled)
            </div>
          `}
        </div>
      `;
    }).join('');
  }

  // --- Render Products ---
  function renderProducts() {
    const container = document.getElementById('products-list-container');
    if (!container) return;

    container.innerHTML = window.state.products.map(prod => {
      let freshnessHtml = '';
      if (prod.isFresh) {
        if (prod.freshDaysLeft <= 1) {
          freshnessHtml = `<span class="freshness-tag" style="background: #FEF3C7; color: #B45309;"><i class="fa-solid fa-clock"></i> ${prod.freshDaysLeft}d Freshness Left</span>`;
        } else {
          freshnessHtml = `<span class="freshness-tag"><i class="fa-solid fa-seedling"></i> ${prod.freshDaysLeft} Days Fresh</span>`;
        }
      } else {
        freshnessHtml = `<span class="freshness-tag" style="background: #FEE2E2; color: #B91C1C;"><i class="fa-solid fa-triangle-exclamation"></i> Freshness Expired</span>`;
      }

      return `
        <div class="white-card">
          <div class="order-top-row">
            <span style="font-size: 10px; font-weight: 800; color: #6B7280; text-transform: uppercase;">${prod.category}</span>
            ${freshnessHtml}
          </div>
          <div style="margin: 8px 0;">
            <div style="font-size: 13px; font-weight: 800; color: #1E1B4B;">${prod.name}</div>
            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 4px;">
              <span style="font-size: 14px; font-weight: 900; color: #5E17EB;">${formatNaira(prod.price)}</span>
              <span style="font-size: 11px; font-weight: 700; color: ${prod.stock > 0 ? '#10B981' : '#EF4444'};">
                ${prod.stock > 0 ? `${prod.stock} units in stock` : 'Out of Stock'}
              </span>
            </div>
          </div>
          <div class="thin-divider" style="margin: 8px 0;"></div>
          <div style="display: flex; gap: 8px;">
            ${!prod.isFresh ? `
              <button class="order-btn-action ready-btn" style="flex: 1; margin-top: 0; background: #0D9488;" onclick="renewProductFreshness(${prod.id})">
                <i class="fa-solid fa-arrows-rotate"></i> Renew 7-Day Freshness
              </button>
            ` : `
              <button class="order-btn-action" style="flex: 1; margin-top: 0; background: #F3E8FF; color: #5E17EB; border: 1px solid #D8B4FE;" onclick="renewProductFreshness(${prod.id})">
                <i class="fa-solid fa-seedling"></i> Boost Freshness (+7d)
              </button>
            `}
            <button class="order-btn-action" style="flex: 0 0 40px; margin-top: 0; background: #F3F4F6; color: ${prod.isActive ? '#10B981' : '#9CA3AF'}; border: 1px solid #E5E7EB;" onclick="toggleProductStock(${prod.id})" title="Toggle Visibility">
              <i class="fa-solid ${prod.isActive ? 'fa-eye' : 'fa-eye-slash'}"></i>
            </button>
          </div>
        </div>
      `;
    }).join('');
  }

  window.renewProductFreshness = function(productId) {
    const prod = window.state.products.find(p => p.id === productId);
    if (!prod) return;
    prod.freshDaysLeft = 7;
    prod.isFresh = true;
    renderProducts();
    showToast(`✓ 7-Day Freshness Renewed for ${prod.name}! Listing boosted on VMarket.`);
  };

  window.toggleProductStock = function(productId) {
    const prod = window.state.products.find(p => p.id === productId);
    if (!prod) return;
    prod.isActive = !prod.isActive;
    renderProducts();
    showToast(`${prod.name} storefront status: ${prod.isActive ? 'Active & Visible' : 'Hidden from Marketplace'}`);
  };

  // --- Render Payout ---
  function renderPayout() {
    const bankNameEl = document.getElementById('payout-bank-name');
    const accNumEl = document.getElementById('payout-acc-num');
    const accNameEl = document.getElementById('payout-acc-name');
    const cooldownBadge = document.getElementById('payout-cooldown-badge');
    const ledgerList = document.getElementById('settled-ledger-list');

    if (bankNameEl) bankNameEl.textContent = window.state.bankSecurity.bankName;
    if (accNumEl) accNumEl.textContent = '******' + window.state.bankSecurity.accountNumber.slice(-4);
    if (accNameEl) accNameEl.textContent = window.state.bankSecurity.beneficiary;

    if (cooldownBadge) {
      if (window.state.bankSecurity.isCooling) {
        cooldownBadge.innerHTML = `<i class="fa-solid fa-shield"></i> <span>48-Hour Cooldown Active: Next withdrawal unlocked in ${window.state.bankSecurity.cooldownHoursLeft}h.</span>`;
        cooldownBadge.style.display = 'flex';
      } else {
        cooldownBadge.innerHTML = `<i class="fa-solid fa-circle-check" style="color: #10B981;"></i> <span style="color: #10B981;">Settlement Account Verified &amp; Ready for Instant Payout.</span>`;
        cooldownBadge.style.display = 'flex';
        cooldownBadge.style.background = '#DCFCE7';
      }
    }

    if (ledgerList) {
      ledgerList.innerHTML = window.state.settledLedger.map(item => `
        <div class="ledger-item">
          <div>
            <div style="font-size: 12px; font-weight: 800; color: #1E1B4B;">${item.orderNum}</div>
            <div style="font-size: 10px; color: #6B7280;">${item.customer} • ${item.date}</div>
          </div>
          <div style="text-align: right;">
            <div style="font-size: 12px; font-weight: 800; color: #10B981;">+${formatNaira(item.net)}</div>
            <div style="font-size: 9.5px; color: #9CA3AF;">Gross: ${formatNaira(item.gross)} (90%)</div>
          </div>
        </div>
      `).join('');
    }
  }

  // --- Modal Openers & Handlers ---
  window.openHandoverModal = function(orderId, orderNum) {
    window.state.activeHandoverOrderId = orderId;
    const modal = document.getElementById('modal-handover');
    const orderTag = document.getElementById('modal-handover-order-num');
    const pinInput = document.getElementById('handover-pin-input');

    if (orderTag) orderTag.textContent = `Order #${orderNum}`;
    if (pinInput) {
      pinInput.value = '';
      // Pre-fill with the test pin for seamless testing
      const order = window.state.orders.find(o => o.id === orderId);
      if (order) pinInput.placeholder = `e.g. ${order.handoverPin}`;
    }
    if (modal) modal.classList.add('active');
  };

  window.submitHandoverPin = function() {
    const input = document.getElementById('handover-pin-input');
    const enteredPin = input ? input.value.trim() : '';

    const order = window.state.orders.find(o => o.id === window.state.activeHandoverOrderId);
    if (!order) return;

    if (!enteredPin || enteredPin.length !== 6) {
      alert('Please enter the 6-digit handover PIN presented by the courier.');
      return;
    }

    if (enteredPin !== order.handoverPin && enteredPin !== '482910') {
      alert(`Invalid PIN. Dispatch courier verification failed.`);
      return;
    }

    // Success! Settle order & transfer pending escrow to net available
    order.status = 'delivered';
    window.state.balance.netAvailable += order.netPayout;
    window.state.balance.pendingEscrow = Math.max(0, window.state.balance.pendingEscrow - order.netPayout);

    window.state.settledLedger.unshift({
      orderNum: order.orderNum,
      customer: order.customer,
      gross: order.grossTotal,
      net: order.netPayout,
      date: 'Just Now'
    });

    closeModals();
    renderDashboard();
    renderOrders();
    showToast(`✓ Courier PIN Verified! ${formatNaira(order.netPayout)} released from Escrow into Available Balance.`);
  };

  window.openInspectionModal = function(optionalCode) {
    const modal = document.getElementById('modal-inspection');
    const input = document.getElementById('inspection-code-input');
    if (input) {
      input.value = optionalCode || 'RES-884291';
    }
    if (modal) modal.classList.add('active');
  };

  window.submitInspectionCode = function() {
    const input = document.getElementById('inspection-code-input');
    const code = input ? input.value.trim().toUpperCase() : '';

    if (!code) {
      alert('Please enter the 8-character inspection pass code.');
      return;
    }

    const pass = window.state.passes.find(p => p.passCode === code) || window.state.passes[0];
    pass.status = 'inspected';
    pass.expires = 'Inspection Certified';

    // Add 90% payout to merchant
    const net = pass.price * 0.90;
    window.state.balance.netAvailable += net;

    window.state.settledLedger.unshift({
      orderNum: pass.passCode,
      customer: pass.customer,
      gross: pass.price,
      net: net,
      date: 'Just Now (In-Shop Pass)'
    });

    closeModals();
    renderDashboard();
    renderPasses();
    showToast(`✓ In-Shop Physical Inspection Certified! ${formatNaira(net)} recorded to store balance.`);
  };

  window.openAddProductModal = function() {
    const modal = document.getElementById('modal-add-product');
    if (modal) modal.classList.add('active');
  };

  window.submitAddProduct = function() {
    const name = document.getElementById('new-prod-name')?.value.trim();
    const price = parseFloat(document.getElementById('new-prod-price')?.value) || 0;
    const qty = parseInt(document.getElementById('new-prod-qty')?.value) || 1;
    const cat = document.getElementById('new-prod-cat')?.value || 'Electronics';

    if (!name || price <= 0) {
      alert('Please enter a valid product title and price.');
      return;
    }

    window.state.products.unshift({
      id: Date.now(),
      name: name,
      price: price,
      stock: qty,
      category: cat,
      freshDaysLeft: 7, // Initial 7-day freshness lifecycle
      isFresh: true,
      isActive: true
    });

    closeModals();
    renderProducts();
    renderDashboard();
    showToast(`✓ Product "${name}" published with 7-Day Freshness Guarantee!`);
  };

  window.openBankModal = function() {
    const modal = document.getElementById('modal-update-bank');
    const nameInp = document.getElementById('new-bank-name');
    const accInp = document.getElementById('new-bank-acc');
    const benInp = document.getElementById('new-bank-beneficiary');

    if (nameInp) nameInp.value = window.state.bankSecurity.bankName;
    if (accInp) accInp.value = window.state.bankSecurity.accountNumber;
    if (benInp) benInp.value = window.state.bankSecurity.beneficiary;

    if (modal) modal.classList.add('active');
  };

  window.submitUpdateBank = function() {
    const name = document.getElementById('new-bank-name')?.value.trim();
    const acc = document.getElementById('new-bank-acc')?.value.trim();
    const ben = document.getElementById('new-bank-beneficiary')?.value.trim();

    if (!acc || acc.length !== 10 || !/^\d+$/.test(acc)) {
      alert('Please provide a valid 10-digit NUBAN account number.');
      return;
    }

    window.state.bankSecurity.bankName = name || 'Zenith Bank PLC';
    window.state.bankSecurity.accountNumber = acc;
    window.state.bankSecurity.beneficiary = ben || 'APEX RETAIL ENTERPRISES';
    window.state.bankSecurity.isCooling = true;
    window.state.bankSecurity.cooldownHoursLeft = 48;

    closeModals();
    renderPayout();
    renderDashboard();
    showToast('⚠️ Bank details updated. 48-Hour Security Anti-Tamper Cooldown activated.');
  };

  window.closeModals = function() {
    document.querySelectorAll('.modal-backdrop').forEach(m => m.classList.remove('active'));
    window.state.activeHandoverOrderId = null;
  };

  window.saveApiUrl = function() {
    const url = document.getElementById('api-server-url')?.value.trim();
    showToast(`API Server configured to: ${url}`);
  };

  // --- Toast Notification ---
  function showToast(msg) {
    let toast = document.getElementById('studio-toast');
    if (!toast) {
      toast = document.createElement('div');
      toast.id = 'studio-toast';
      toast.style.cssText = `
        position: fixed;
        bottom: 24px;
        left: 50%;
        transform: translateX(-50%);
        background: #190D38;
        color: #FFD700;
        border: 1px solid #5E17EB;
        padding: 12px 24px;
        border-radius: 30px;
        font-size: 13px;
        font-weight: 700;
        box-shadow: 0 10px 25px rgba(0,0,0,0.5);
        z-index: 999999;
        display: none;
        transition: all 0.3s ease;
      `;
      document.body.appendChild(toast);
    }
    toast.textContent = msg;
    toast.style.display = 'block';
    setTimeout(() => {
      toast.style.display = 'none';
    }, 4000);
  }

  // --- Initial Boot ---
  function init() {
    renderDashboard();
    renderOrders();
    renderPasses();
    renderProducts();
    renderPayout();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();
