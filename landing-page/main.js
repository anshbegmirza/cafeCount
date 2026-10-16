(() => {
  /** Set this when the Drive APK link is ready */
  const DOWNLOAD_URL = "";

  const yearEl = document.querySelector("[data-year]");
  if (yearEl) yearEl.textContent = String(new Date().getFullYear());

  const toastEl = document.querySelector("[data-toast]");
  let toastTimer = 0;
  const showToast = (msg) => {
    if (!toastEl) return;
    toastEl.textContent = msg;
    toastEl.classList.add("is-on");
    window.clearTimeout(toastTimer);
    toastTimer = window.setTimeout(() => toastEl.classList.remove("is-on"), 2600);
  };

  const i18n = {
    en: {
      skip: "Skip to content",
      nav_platform: "Platform",
      nav_product: "Product",
      nav_how: "How it works",
      nav_roles: "Roles",
      nav_stack: "Stack",
      nav_faq: "FAQ",
      nav_contact: "Contact",
      nav_demo: "Live Demo",
      kicker: "Inventory control for cafés — EN + Arabic",
      lede: "Stock in. Stock out. Full history. One app.",
      cta_download: "Download now",
      cta_explore: "Explore the product",
      cta_how: "See how it works",
      cta_demo_soon: "Live Demo",
      seo_line: "Cafe stock management for daily ops — built by <strong>Ansh Beg Mirza</strong>.",
      strip: ["Products", "Withdraw", "History", "Staff", "Reports", "Low stock", "EN + Arabic", "Roles"],
      plat_eyebrow: "Why Hidden Room",
      plat_title: "Stock that stays<br />under control.",
      plat_lead:
        "Built for café floors — fast withdraw for staff, full control for admins, clear history for everyone.",
      f1_tag: "Operations",
      f1_title: "Products & stock at a glance",
      f1_body: "See quantities, low-stock alerts, and categories without digging through sheets.",
      f1_t1: "Live stock levels",
      f1_t2: "Add products with units",
      f1_t3: "Low-stock visibility on home",
      f2_tag: "Floor speed",
      f2_title: "Withdraw in seconds",
      f2_body: "Employees pull stock fast. The app blocks negative stock so counts stay honest.",
      f2_t1: "One-tap withdraw flow",
      f2_t2: "No negative stock",
      f2_t3: "Notes when you need them",
      f3_tag: "Accountability",
      f3_title: "Full history & reports",
      f3_body: "Every add, withdraw, and adjust is logged. Export PDF or Excel when you need a paper trail.",
      f3_t1: "Append-only stock history",
      f3_t2: "Date filters",
      f3_t3: "Admin PDF / Excel export",
      prod_eyebrow: "The product",
      prod_title: "Cafe inventory<br />that just runs.",
      prod_lead: "One Android app for stock in, stock out, and full history.",
      gal_kicker: "Inside the product",
      gal_note: "Tap a screen to expand.",
      chip_overview: "Overview",
      chip_stock: "Stock",
      chip_staff: "Staff",
      chip_reports: "Reports",
      s_admin: "Admin",
      s_emp: "Employee",
      s_flow: "Flow",
      s_home: "Home dashboard",
      s_activity: "Recent activity",
      s_menu: "Drawer menu",
      s_products: "Products",
      s_add: "Add product",
      s_sheet: "Product sheet",
      s_withdraw: "Withdraw stock",
      s_history: "Stock history",
      s_dates: "Date filters",
      s_staff: "Staff",
      s_reports: "Reports",
      s_settings: "Settings",
      s_login: "Login",
      s_splash: "Splash",
      s_emp_home: "Home + withdraw",
      s_emp_menu: "Employee menu",
      s_stats: "Stats + low stock",
      s_tagline: "Splash tagline",
      s_after: "After splash",
      s_fab: "Add sheet open",
      how_eyebrow: "How it works",
      how_title: "Two roles.<br />One clear flow.",
      how_lead: "Admins set the shop up. Employees keep stock moving.",
      step1_role: "Admin",
      step1_title: "Admin sets products",
      step1_body: "Add products, set units and min stock, invite staff.",
      step2_role: "Employee",
      step2_title: "Employee withdraws",
      step2_body: "Open withdraw, pick the item, confirm. History logs it.",
      step3_role: "Admin",
      step3_title: "Admin reviews",
      step3_body: "Check low stock, scan history, export reports.",
      roles_eyebrow: "Roles",
      roles_title: "Admin vs employee",
      roles_lead: "Each login sees only what they need.",
      role_admin: "Shop Admin",
      role_admin_d: "Full control of products, stock, staff, and exports.",
      ra1: "Products & min stock",
      ra2: "Add / adjust stock",
      ra3: "Manage staff",
      ra4: "PDF & Excel reports",
      role_emp: "Employee",
      role_emp_d: "Fast withdraw and view-only history.",
      re1: "Withdraw stock",
      re2: "View stock & history",
      re3: "No staff / reports",
      re4: "Simple home CTA",
      stack_eyebrow: "Tech stack",
      stack_title: "Built with tools that last.",
      stack_body: "Flutter app, Node API, MySQL data — ready for a café floor.",
      demo_eyebrow: "Try it",
      demo_title: "Download Hidden Room<br />when the APK is ready.",
      df1: "Login",
      df2: "Home",
      df3: "Withdraw",
      df4: "History",
      demo_body: "Same flow your team would use every day.",
      faq_eyebrow: "FAQ",
      faq_title: "Common questions",
      faq_lead: "Straight answers about roles, stock, language, and reports.",
      faq1_q: "What is Hidden Room?",
      faq1_a:
        "Hidden Room is a coffee shop stock app. Track products, withdraw stock, see history, manage staff, and export reports — all on Android.",
      faq2_q: "Who is it for?",
      faq2_a:
        "Cafe owners and floor staff. Admins manage products, stock, and people. Employees withdraw stock fast and view history.",
      faq3_q: "What can employees do?",
      faq3_a:
        "Withdraw stock, view current levels, and check stock history. They cannot add products, adjust stock, manage staff, or export reports.",
      faq4_q: "What can admins do?",
      faq4_a:
        "Everything employees can, plus: add/edit products, add or adjust stock, set min stock and units, manage staff, and export PDF/Excel reports.",
      faq5_q: "Can stock go negative?",
      faq5_a: "No. If a withdraw would drop below zero, the app blocks it.",
      faq6_q: "Is there a full stock history?",
      faq6_a:
        "Yes. Every add, withdraw, and adjust is logged (who, what, before/after qty, time). History is append-only — past moves are not edited or deleted.",
      faq7_q: "Does it support Arabic?",
      faq7_a:
        "Yes. English and Arabic with full RTL. Product names and units stay in English.",
      faq8_q: "How do people get accounts?",
      faq8_a:
        "There is no public signup. An admin creates staff accounts (username/email + password). Users then log in on the app.",
      faq9_q: "Can I export reports?",
      faq9_a:
        "Yes — admins can download stock as PDF or Excel. Employees cannot export.",
      contact_eyebrow: "Contact",
      contact_title: "Built by Ansh Beg Mirza",
      contact_body:
        "Hidden Room is a café stock product for daily operations. Reach out through the portfolio for demos and handoff.",
      contact_cta: "Open portfolio",
      toast_download: "Download link coming soon.",
      toast_demo: "Live demo is not connected yet.",
    },
    ar: {
      skip: "تخطي إلى المحتوى",
      nav_platform: "المنصة",
      nav_product: "المنتج",
      nav_how: "كيف يعمل",
      nav_roles: "الأدوار",
      nav_stack: "التقنية",
      nav_faq: "أسئلة",
      nav_contact: "تواصل",
      nav_demo: "تجربة مباشرة",
      kicker: "إدارة مخزون المقاهي — إنجليزي + عربي",
      lede: "إدخال مخزون. سحب مخزون. سجل كامل. تطبيق واحد.",
      cta_download: "حمّل الآن",
      cta_explore: "استكشف المنتج",
      cta_how: "شاهد كيف يعمل",
      cta_demo_soon: "تجربة مباشرة",
      seo_line: "إدارة مخزون المقهى للعمليات اليومية — من تطوير <strong>Ansh Beg Mirza</strong>.",
      strip: ["المنتجات", "السحب", "السجل", "الموظفون", "التقارير", "مخزون منخفض", "إنجليزي + عربي", "الأدوار"],
      plat_eyebrow: "لماذا Hidden Room",
      plat_title: "مخزون يبقى<br />تحت السيطرة.",
      plat_lead: "مصمم لأرضية المقهى — سحب سريع للموظفين، تحكم كامل للمدراء، وسجل واضح للجميع.",
      f1_tag: "العمليات",
      f1_title: "المنتجات والمخزون بنظرة واحدة",
      f1_body: "شاهد الكميات وتنبيهات المخزون المنخفض دون جداول معقدة.",
      f1_t1: "مستويات مخزون مباشرة",
      f1_t2: "إضافة منتجات مع الوحدات",
      f1_t3: "ظهور المخزون المنخفض في الرئيسية",
      f2_tag: "سرعة الأرضية",
      f2_title: "سحب خلال ثوانٍ",
      f2_body: "الموظفون يسحبون بسرعة. التطبيق يمنع المخزون السالب.",
      f2_t1: "تدفق سحب سريع",
      f2_t2: "لا مخزون سالب",
      f2_t3: "ملاحظات عند الحاجة",
      f3_tag: "المحاسبة",
      f3_title: "سجل كامل وتقارير",
      f3_body: "كل إدخال وسحب وتعديل مسجّل. صدّر PDF أو Excel عند الحاجة.",
      f3_t1: "سجل مخزون للإضافة فقط",
      f3_t2: "فلاتر بالتاريخ",
      f3_t3: "تصدير PDF / Excel للمدراء",
      prod_eyebrow: "المنتج",
      prod_title: "مخزون المقهى<br />يعمل ببساطة.",
      prod_lead: "تطبيق أندرويد واحد لإدخال المخزون وسحبه وسجله الكامل.",
      gal_kicker: "داخل المنتج",
      gal_note: "اضغط على شاشة للتكبير.",
      chip_overview: "نظرة عامة",
      chip_stock: "المخزون",
      chip_staff: "الموظفون",
      chip_reports: "التقارير",
      s_admin: "مدير",
      s_emp: "موظف",
      s_flow: "تدفق",
      s_home: "لوحة الرئيسية",
      s_activity: "النشاط الأخير",
      s_menu: "القائمة",
      s_products: "المنتجات",
      s_add: "إضافة منتج",
      s_sheet: "ورقة المنتج",
      s_withdraw: "سحب المخزون",
      s_history: "سجل المخزون",
      s_dates: "فلاتر التاريخ",
      s_staff: "الموظفون",
      s_reports: "التقارير",
      s_settings: "الإعدادات",
      s_login: "تسجيل الدخول",
      s_splash: "شاشة البداية",
      s_emp_home: "رئيسية + سحب",
      s_emp_menu: "قائمة الموظف",
      s_stats: "إحصائيات + منخفض",
      s_tagline: "شعار البداية",
      s_after: "بعد البداية",
      s_fab: "فتح الإضافة",
      how_eyebrow: "كيف يعمل",
      how_title: "دوران.<br />تدفق واحد واضح.",
      how_lead: "المدير يجهّز المتجر. الموظف يحرّك المخزون.",
      step1_role: "مدير",
      step1_title: "المدير يضيف المنتجات",
      step1_body: "أضف المنتجات والوحدات والحد الأدنى، وادعُ الموظفين.",
      step2_role: "موظف",
      step2_title: "الموظف يسحب",
      step2_body: "افتح السحب، اختر الصنف، أكّد. السجل يسجّل العملية.",
      step3_role: "مدير",
      step3_title: "المدير يراجع",
      step3_body: "راجع المخزون المنخفض والسجل وصدّر التقارير.",
      roles_eyebrow: "الأدوار",
      roles_title: "المدير مقابل الموظف",
      roles_lead: "كل دخول يرى ما يحتاجه فقط.",
      role_admin: "مدير المتجر",
      role_admin_d: "تحكم كامل بالمنتجات والمخزون والموظفين والتصدير.",
      ra1: "المنتجات والحد الأدنى",
      ra2: "إضافة / تعديل المخزون",
      ra3: "إدارة الموظفين",
      ra4: "تقارير PDF و Excel",
      role_emp: "موظف",
      role_emp_d: "سحب سريع وسجل للعرض فقط.",
      re1: "سحب المخزون",
      re2: "عرض المخزون والسجل",
      re3: "بدون موظفين / تقارير",
      re4: "زر سحب في الرئيسية",
      stack_eyebrow: "التقنية",
      stack_title: "مبني بأدوات تدوم.",
      stack_body: "تطبيق Flutter وواجهة Node وبيانات MySQL — جاهز لأرضية المقهى.",
      demo_eyebrow: "جرّبه",
      demo_title: "حمّل Hidden Room<br />عند جاهزية ملف APK.",
      df1: "دخول",
      df2: "رئيسية",
      df3: "سحب",
      df4: "سجل",
      demo_body: "نفس التدفق الذي يستخدمه فريقك يومياً.",
      faq_eyebrow: "أسئلة",
      faq_title: "أسئلة شائعة",
      faq_lead: "إجابات واضحة عن الأدوار والمخزون واللغة والتقارير.",
      faq1_q: "ما هو Hidden Room؟",
      faq1_a:
        "Hidden Room تطبيق مخزون للمقاهي. تتبع المنتجات، سحب المخزون، السجل، الموظفين، وتصدير التقارير — على أندرويد.",
      faq2_q: "لمن هو؟",
      faq2_a:
        "لأصحاب المقاهي وموظفي الصالة. المدراء يديرون المنتجات والمخزون والأشخاص. الموظفون يسحبون المخزون بسرعة ويعرضون السجل.",
      faq3_q: "ماذا يستطيع الموظف فعله؟",
      faq3_a:
        "سحب المخزون، عرض الكميات الحالية، ومراجعة سجل المخزون. لا يمكنه إضافة منتجات أو تعديل المخزون أو إدارة الموظفين أو تصدير التقارير.",
      faq4_q: "ماذا يستطيع المدير فعله؟",
      faq4_a:
        "كل ما يستطيعه الموظف، إضافةً إلى: إضافة/تعديل المنتجات، إضافة أو تعديل المخزون، تعيين الحد الأدنى والوحدات، إدارة الموظفين، وتصدير PDF/Excel.",
      faq5_q: "هل يمكن أن يصبح المخزون سالباً؟",
      faq5_a: "لا. إذا كان السحب سينزل تحت الصفر، يرفضه التطبيق.",
      faq6_q: "هل يوجد سجل مخزون كامل؟",
      faq6_a:
        "نعم. كل إضافة وسحب وتعديل يُسجَّل (من، ماذا، الكمية قبل/بعد، الوقت). السجل للإضافة فقط — لا تعديل ولا حذف للحركات السابقة.",
      faq7_q: "هل يدعم العربية؟",
      faq7_a:
        "نعم. إنجليزي وعربي مع RTL كامل. أسماء المنتجات والوحدات تبقى بالإنجليزية.",
      faq8_q: "كيف يحصل الناس على حسابات؟",
      faq8_a:
        "لا يوجد تسجيل عام. المدير ينشئ حسابات الموظفين (اسم مستخدم/بريد + كلمة مرور)، ثم يسجّلون الدخول في التطبيق.",
      faq9_q: "هل يمكنني تصدير التقارير؟",
      faq9_a:
        "نعم — المدراء يمكنهم تنزيل المخزون كـ PDF أو Excel. الموظفون لا يمكنهم التصدير.",
      contact_eyebrow: "تواصل",
      contact_title: "من تطوير Ansh Beg Mirza",
      contact_body:
        "Hidden Room منتج مخزون للمقاهي. تواصل عبر المعرض للعروض والتسليم.",
      contact_cta: "افتح المعرض",
      toast_download: "رابط التحميل قريباً.",
      toast_demo: "التجربة المباشرة غير متصلة بعد.",
    },
  };

  let lang = localStorage.getItem("hr-landing-lang") || "en";

  const applyLang = (next) => {
    lang = next;
    localStorage.setItem("hr-landing-lang", lang);
    const dict = i18n[lang] || i18n.en;
    const root = document.documentElement;
    root.lang = lang;
    root.dir = lang === "ar" ? "rtl" : "ltr";

    document.querySelectorAll("[data-lang]").forEach((btn) => {
      btn.classList.toggle("is-active", btn.getAttribute("data-lang") === lang);
    });

    document.querySelectorAll("[data-i18n]").forEach((el) => {
      const key = el.getAttribute("data-i18n");
      if (key && dict[key] != null) el.textContent = dict[key];
    });

    document.querySelectorAll("[data-i18n-html]").forEach((el) => {
      const key = el.getAttribute("data-i18n-html");
      if (key && dict[key] != null) el.innerHTML = dict[key];
    });

    const strip = document.querySelector("[data-i18n-strip]");
    if (strip && Array.isArray(dict.strip)) {
      const doubled = [...dict.strip, ...dict.strip];
      strip.innerHTML = doubled.map((t) => `<span>${t}</span>`).join("");
    }

  };

  document.querySelectorAll("[data-lang]").forEach((btn) => {
    btn.addEventListener("click", () => applyLang(btn.getAttribute("data-lang") || "en"));
  });
  applyLang(lang);

  document.querySelectorAll("[data-download]").forEach((el) => {
    el.addEventListener("click", (e) => {
      if (DOWNLOAD_URL) {
        el.setAttribute("href", DOWNLOAD_URL);
        el.setAttribute("target", "_blank");
        el.setAttribute("rel", "noopener noreferrer");
        return;
      }
      e.preventDefault();
      showToast(i18n[lang].toast_download);
    });
  });

  document.querySelectorAll("[data-live-demo]").forEach((el) => {
    el.addEventListener("click", (e) => {
      e.preventDefault();
      showToast(i18n[lang].toast_demo);
    });
  });

  const faqList = document.querySelector("[data-faq-list]");
  if (faqList) {
    faqList.addEventListener("toggle", (e) => {
      const target = e.target;
      if (!(target instanceof HTMLDetailsElement) || !target.open) return;
      faqList.querySelectorAll("details[open]").forEach((el) => {
        if (el !== target) el.removeAttribute("open");
      });
    }, true);
  }

  const header = document.querySelector("[data-header]");
  const darkSections = [...document.querySelectorAll(".zone-dark")];

  const syncHeader = () => {
    if (!header) return;
    header.classList.toggle("is-scrolled", window.scrollY > 8);
    const y = window.scrollY + 64;
    const onDark = darkSections.some((s) => {
      const top = s.offsetTop;
      return y >= top && y < top + s.offsetHeight;
    });
    header.classList.toggle("on-dark", onDark);
  };
  window.addEventListener("scroll", syncHeader, { passive: true });
  syncHeader();

  const toggle = document.querySelector("[data-nav-toggle]");
  const mobileNav = document.querySelector("[data-mobile-nav]");
  if (toggle && mobileNav) {
    toggle.addEventListener("click", () => {
      const open = mobileNav.hasAttribute("hidden");
      if (open) mobileNav.removeAttribute("hidden");
      else mobileNav.setAttribute("hidden", "");
      toggle.setAttribute("aria-expanded", String(open));
    });
    mobileNav.querySelectorAll("a,button").forEach((a) => {
      a.addEventListener("click", () => {
        mobileNav.setAttribute("hidden", "");
        toggle.setAttribute("aria-expanded", "false");
      });
    });
  }

  const showcaseSets = {
    overview: [
      { src: "assets/screenshots/a54_admin_01_home.png", labelKey: "s_home" },
      { src: "assets/screenshots/a54_en_03_products.png", labelKey: "s_products" },
      { src: "assets/screenshots/a54_en_06_withdraw.png", labelKey: "s_withdraw" },
    ],
    stock: [
      { src: "assets/screenshots/a54_en_06_withdraw.png", labelKey: "s_withdraw" },
      { src: "assets/screenshots/a54_en_07_history.png", labelKey: "s_history" },
      { src: "assets/screenshots/a54_en_05_add_product_sheet.png", labelKey: "s_add" },
    ],
    staff: [
      { src: "assets/screenshots/a54_en_09_staff.png", labelKey: "s_staff" },
      { src: "assets/screenshots/a54_emp_09_home.png", labelKey: "s_emp_home" },
      { src: "assets/screenshots/a54_emp_10_drawer.png", labelKey: "s_emp_menu" },
    ],
    reports: [
      { src: "assets/screenshots/a54_en_10_reports.png", labelKey: "s_reports" },
      { src: "assets/screenshots/a54_en_08_history_from.png", labelKey: "s_dates" },
      { src: "assets/screenshots/a54_en_11_settings.png", labelKey: "s_settings" },
    ],
  };

  let activeSet = "overview";
  const chipBtns = [...document.querySelectorAll("#screenshots [data-set]")];
  const slots = [...document.querySelectorAll("#screenshots .shot[data-slot]")];

  const applyShowcase = (setId) => {
    const set = showcaseSets[setId] || showcaseSets.overview;
    activeSet = setId;
    const dict = i18n[lang] || i18n.en;
    slots.forEach((shot, i) => {
      const item = set[i];
      if (!item) return;
      const img = shot.querySelector("img");
      const meta = shot.querySelector(".shot-meta");
      const label = dict[item.labelKey] || item.labelKey;
      shot.setAttribute("data-full", item.src);
      if (img) {
        img.src = item.src;
        img.alt = label;
      }
      if (meta) meta.textContent = label;
    });
    chipBtns.forEach((chip) => {
      const on = chip.getAttribute("data-set") === setId;
      chip.classList.toggle("is-active", on);
      chip.setAttribute("aria-selected", String(on));
    });
  };

  chipBtns.forEach((chip) => {
    chip.addEventListener("click", () => applyShowcase(chip.getAttribute("data-set") || "overview"));
  });
  applyShowcase("overview");

  document.querySelectorAll("[data-lang]").forEach((btn) => {
    btn.addEventListener("click", () => applyShowcase(activeSet));
  });

  const lightbox = document.querySelector("[data-lightbox]");
  const lightboxImg = document.querySelector("[data-lightbox-img]");
  const closeBtn = document.querySelector("[data-lightbox-close]");

  const closeLightbox = () => {
    if (!lightbox) return;
    lightbox.setAttribute("hidden", "");
    document.body.style.overflow = "";
  };

  const openLightbox = (src, alt) => {
    if (!lightbox || !lightboxImg || !src) return;
    lightboxImg.src = src;
    lightboxImg.alt = alt || "Screenshot";
    lightbox.removeAttribute("hidden");
    document.body.style.overflow = "hidden";
    closeBtn?.focus();
  };

  slots.forEach((shot) => {
    shot.addEventListener("click", () => {
      openLightbox(shot.getAttribute("data-full"), shot.querySelector("img")?.alt);
    });
  });
  closeBtn?.addEventListener("click", closeLightbox);
  lightbox?.addEventListener("click", (e) => {
    if (e.target === lightbox) closeLightbox();
  });
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeLightbox();
  });

  const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  if (reduce || typeof gsap === "undefined") return;

  gsap.registerPlugin(ScrollTrigger);

  gsap.from(gsap.utils.toArray("[data-hero]"), {
    y: 36,
    opacity: 0,
    duration: 0.9,
    stagger: 0.12,
    ease: "power3.out",
  });

  gsap.from("[data-hero-stage]", {
    y: 56,
    opacity: 0,
    duration: 1.15,
    delay: 0.25,
    ease: "power3.out",
  });

  gsap.to(".hero-float-a", {
    y: -18,
    duration: 3.2,
    yoyo: true,
    repeat: -1,
    ease: "sine.inOut",
  });
  gsap.to(".hero-float-b", {
    y: 16,
    duration: 3.8,
    yoyo: true,
    repeat: -1,
    ease: "sine.inOut",
    delay: 0.4,
  });

  gsap.utils.toArray("[data-reveal]").forEach((el) => {
    gsap.from(el, {
      scrollTrigger: {
        trigger: el,
        start: "top 88%",
        toggleActions: "play none none none",
      },
      y: 40,
      opacity: 0,
      duration: 0.85,
      ease: "power2.out",
    });
  });

  const stage = document.querySelector("[data-hero-stage]");
  if (stage) {
    gsap.to(stage, {
      y: -40,
      ease: "none",
      scrollTrigger: {
        trigger: ".hero",
        start: "top top",
        end: "bottom top",
        scrub: true,
      },
    });
  }
})();
