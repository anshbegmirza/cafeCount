import {
  Callout,
  Card,
  CardBody,
  CardHeader,
  Code,
  Divider,
  Grid,
  H1,
  H2,
  H3,
  Pill,
  Row,
  Spacer,
  Stack,
  Stat,
  Table,
  Text,
  useCanvasState,
} from "cursor/canvas";

type View = "overview" | "working" | "broken" | "by-role";
type Severity = "Blocker" | "Major" | "Minor";

type Issue = {
  id: string;
  severity: Severity;
  roles: string;
  title: string;
  where: string;
  what: string;
  tip: string;
  confidence: "Confirmed in code" | "Confirmed via API + code" | "Likely at runtime";
};

const ISSUES: Issue[] = [
  {
    id: "B1",
    severity: "Blocker",
    roles: "All",
    title: "Login blanks the whole screen",
    where: "mobile/lib/app.dart (home gate) + mobile/lib/features/auth/auth_provider.dart login()",
    what: "Tap Login → form unmounts → empty paper Scaffold while loading → then Home or error. Feels broken on every role.",
    tip: "Split restore vs login. Keep LoginScreen mounted during login (it already has a button spinner). Only show the blank Scaffold for cold-start token restore.",
    confidence: "Confirmed in code",
  },
  {
    id: "M1",
    severity: "Major",
    roles: "superadmin, shopadmin",
    title: "Cannot reactivate staff in the UI",
    where: "mobile/lib/features/staff/staff_screen.dart — _actions / _deactivate",
    what: "Deactivate works. Inactive users get no Activate action. API PATCH /users/:id/active with isActive:true works (verified).",
    tip: "If !active, show Activate → setUserActive(id, true) and invalidate staffProvider. Tiny UI gap; backend is ready.",
    confidence: "Confirmed via API + code",
  },
  {
    id: "M2",
    severity: "Major",
    roles: "superadmin, shopadmin",
    title: "Edit staff is a dead-end view",
    where: "mobile/lib/features/staff/staff_screen.dart — _editStaff",
    what: "Menu says Edit staff, sheet is read-only username/email/role with Cancel only. User expects to save changes.",
    tip: "For MVP: rename to View staff (or remove the tile). Real edit needs PATCH /users/:id for profile fields — don't fake a form.",
    confidence: "Confirmed in code",
  },
  {
    id: "M3",
    severity: "Major",
    roles: "shopadmin",
    title: "Shop admin sees forbidden superadmin actions",
    where: "mobile/lib/features/staff/staff_screen.dart — _actions (no role guard)",
    what: "Shop admin can open Change password / Deactivate on the superadmin row. Backend correctly returns 403 — user gets a toast, not a clean UI.",
    tip: "Hide password/deactivate when target.role == 'super_admin' and actor is not super_admin. Mirror backend rules in the sheet.",
    confidence: "Confirmed via API + code",
  },
  {
    id: "M4",
    severity: "Major",
    roles: "All",
    title: "History date filter only searches the last 100 moves",
    where: "mobile/lib/features/catalog/catalog_api.dart historyProvider (limit: '100'); filter in history_screen.dart",
    what: "Live DB has 900+ txs. Mobile loads 100. Oldest in that window was ~2026-10-11. Picking From before that → empty list even though history exists.",
    tip: "Pass from/to to GET /stock/history (add query support in stockController/listHistory). Until then, raise limit and change empty copy when filters are on.",
    confidence: "Confirmed via API + code",
  },
  {
    id: "M5",
    severity: "Major",
    roles: "All",
    title: "Search flashes a full skeleton every keystroke",
    where: "products_screen.dart + withdraw_screen.dart via productsProvider(_q)",
    what: "Each character changes the Riverpod family key → loading skeleton replaces the list. Feels laggy and broken while typing.",
    tip: "Debounce search 250–300ms. Keep previous data while reloading (skipLoadingOnReload / previous value).",
    confidence: "Confirmed in code",
  },
  {
    id: "M6",
    severity: "Major",
    roles: "All",
    title: "Concurrent 401 can force-logout a good session",
    where: "mobile/lib/core/api_client.dart — _tryRefresh",
    what: "If refresh is already in flight, a second 401 caller gets false and calls onSessionExpired. After ~15m access expiry, a burst of requests can kick a valid user to login.",
    tip: "Share one refresh Future; queue waiters. Only expire session when that shared refresh fails.",
    confidence: "Confirmed in code",
  },
  {
    id: "M7",
    severity: "Major",
    roles: "superadmin, shopadmin",
    title: "Add staff Save ignores empty username/email",
    where: "mobile/lib/features/staff/staff_screen.dart — _addStaff",
    what: "Save always closes the sheet. Empty fields → API error toast. Password policy is checked only after dismiss.",
    tip: "Disable Save until username, email, and password pass local checks (same pattern as change-password sheet).",
    confidence: "Confirmed in code",
  },
  {
    id: "N1",
    severity: "Minor",
    roles: "superadmin, shopadmin",
    title: "Soft-deleted products cannot be restored in UI",
    where: "products_screen.dart deactivateProduct; listProducts filters is_active=true",
    what: "Delete/archive hides the product. API restore (isActive:true) works, but no inactive list / Restore action in app.",
    tip: "MVP: rename Delete → Archive and say it is permanent in-app. Or add a simple Inactive filter + Restore.",
    confidence: "Confirmed via API + code",
  },
  {
    id: "N2",
    severity: "Minor",
    roles: "superadmin, shopadmin",
    title: "Add stock does not refresh history cache",
    where: "products_screen.dart — _addStockSheet (no historyProvider invalidate; adjust/withdraw do)",
    what: "After Add stock, History (if already opened) can look stale until pull-to-refresh.",
    tip: "One line: ref.invalidate(historyProvider) after successful add (and after create-with-initialQty).",
    confidence: "Confirmed in code",
  },
  {
    id: "N3",
    severity: "Minor",
    roles: "All",
    title: "Filtered history empty state is wrong",
    where: "history_screen.dart empty branch",
    what: "Date/type filter with no matches still says No stock moves yet + Go to withdraw.",
    tip: "If any filter set → No matches + Clear filters. Keep withdraw CTA only for true empty history.",
    confidence: "Confirmed in code",
  },
  {
    id: "N4",
    severity: "Minor",
    roles: "All",
    title: "Withdraw allows out-of-stock / over-qty",
    where: "withdraw_screen.dart + HrQtyStepper (no max)",
    what: "User can select Out items and qty above available, then hit API STOCK_INSUFFICIENT toast.",
    tip: "Disable/skip out items; cap stepper at currentQty. Cheaper than relying on the 409 alone.",
    confidence: "Confirmed in code",
  },
  {
    id: "N5",
    severity: "Minor",
    roles: "All",
    title: "Qty only via ±1 stepper (hard to enter decimals)",
    where: "hr_widgets.dart HrQtyStepper used in add/adjust/withdraw",
    what: "Cannot type 0.25 / 12.5 quickly; only step by 1 from current value.",
    tip: "Keep stepper; add a small numeric TextField for exact qty. Big UX win for coffee weights.",
    confidence: "Confirmed in code",
  },
  {
    id: "N6",
    severity: "Minor",
    roles: "All (device QA)",
    title: "Android default API host is a hardcoded LAN IP",
    where: "mobile/lib/core/config.dart — apiBase",
    what: "Default http://192.168.0.105:3000/api/v1 fails when DHCP IP changes or on emulator without dart-define. Login looks totally down.",
    tip: "Document --dart-define=API_BASE=... on the QA sheet. Prefer 10.0.2.2 for emulator builds.",
    confidence: "Confirmed in code",
  },
  {
    id: "N7",
    severity: "Minor",
    roles: "superadmin, shopadmin",
    title: "Reports shows Only admins can export to admins",
    where: "reports_screen.dart footer Text(adminsOnlyExport)",
    what: "Admins already on Reports see a muted Only admins can export. Confusing copy, not a functional break.",
    tip: "Remove the line for admin-only screen, or replace with export hint (file saved / open with…).",
    confidence: "Confirmed in code",
  },
  {
    id: "N8",
    severity: "Minor",
    roles: "All",
    title: "Login accepts empty fields",
    where: "login_screen.dart — _submit",
    what: "Empty submit → failed login toast instead of inline validation.",
    tip: "Disable Login until identifier and password are non-empty.",
    confidence: "Confirmed in code",
  },
];

const WORKING = [
  "Seed logins work: superadmin / shopadmin / employee with test123",
  "Wrong password rejected (401); inactive user cannot log in",
  "Auth /me, dashboard totals, low-stock list, recent activity",
  "Role shell: employees do not see Staff / Categories / Units / Reports in drawer",
  "Employee can withdraw + view products/history; add/adjust/users/export blocked (403)",
  "Shop admin ≈ super admin permissions in V1 (by design)",
  "Shop admin cannot deactivate / change password for superadmin (API)",
  "Categories create works; units list seeded + custom units in use",
  "Products CRUD path: create (unit symbol + minStock), edit, soft-delete",
  "Stock add / adjust / withdraw + overdraw blocked (409 STOCK_INSUFFICIENT)",
  "History list API works (cap 100 on mobile / 200 max on server)",
  "Staff create + password change with special-char policy (UI + API aligned)",
  "Staff deactivate + reactivate work on API (UI missing activate)",
  "PDF + Excel export return real files for both admin roles; employee blocked",
  "English strings for main flows resolve (no missing-key crashes spotted)",
  "Settings: language toggle, about, logout confirm",
];

function severityTone(s: Severity): "danger" | "warning" | "info" {
  if (s === "Blocker") return "danger";
  if (s === "Major") return "warning";
  return "info";
}

function rowTone(s: Severity): "danger" | "warning" | "info" | "neutral" {
  if (s === "Blocker") return "danger";
  if (s === "Major") return "warning";
  return "info";
}

export default function MvpE2eQaReport() {
  const [view, setView] = useCanvasState<View>("view", "overview");
  const [sev, setSev] = useCanvasState<Severity | "All">("sev", "All");

  const filtered = ISSUES.filter((i) => sev === "All" || i.severity === sev);
  const blockers = ISSUES.filter((i) => i.severity === "Blocker").length;
  const majors = ISSUES.filter((i) => i.severity === "Major").length;
  const minors = ISSUES.filter((i) => i.severity === "Minor").length;

  return (
    <Stack gap={20} style={{ padding: 20, maxWidth: 960 }}>
      <Stack gap={6}>
        <H1>Stock Room MVP — E2E QA report</H1>
        <Text tone="secondary">
          English-only real-user pass across superadmin, shopadmin, and employee.
          Credentials from docs/SEED_CREDENTIALS.md. Tested against live API on
          :3000 plus Flutter UI code walkthrough of every main screen.
        </Text>
        <Text size="small" tone="tertiary">
          Scope: MVP, not final product. Dark theme / Google auth / multi-shop UI
          are out of V1 and not counted as bugs.
        </Text>
      </Stack>

      <Grid columns={4} gap={12}>
        <Stat value={String(WORKING.length)} label="Working checks" tone="success" />
        <Stat value={String(blockers)} label="Blockers" tone="danger" />
        <Stat value={String(majors)} label="Majors" tone="warning" />
        <Stat value={String(minors)} label="Minors" tone="info" />
      </Grid>

      <Callout tone="warning" title="Top takeaway">
        Core stock + RBAC backend is solid. Biggest user-facing pain: blank login
        flash, staff edit/reactivate gaps, and history date filters that silently
        lie once you have more than 100 moves.
      </Callout>

      <Row gap={8} wrap>
        {(
          [
            ["overview", "Overview"],
            ["working", "Working"],
            ["broken", "Not working"],
            ["by-role", "By role"],
          ] as const
        ).map(([id, label]) => (
          <Pill key={id} active={view === id} onClick={() => setView(id)}>
            {label}
          </Pill>
        ))}
      </Row>

      {view === "overview" && (
        <Stack gap={16}>
          <H2>How this was tested</H2>
          <Text>
            Acted as a real shop user: login each seed account, then walk Home →
            Products → Withdraw → History → Settings. For admins also Staff,
            Categories, Units, Reports (PDF/Excel). Backend assertions hit live
            /api/v1; UI breaks confirmed in Flutter sources listed below.
          </Text>
          <Table
            headers={["Role", "Login", "Core flows", "Notes"]}
            rows={[
              [
                "superadmin",
                "OK",
                "Dashboard, catalog, stock, staff, exports",
                "Same admin UI as shopadmin in V1",
              ],
              [
                "shopadmin",
                "OK",
                "Same admin capabilities",
                "API blocks touching superadmin; UI still offers actions",
              ],
              [
                "employee",
                "OK",
                "Withdraw + view products/history",
                "Admin drawer items hidden; write APIs 403",
              ],
            ]}
            rowTone={["success", "success", "success"]}
          />

          <H2>Fix order (experienced-dev priority)</H2>
          <Table
            headers={["#", "Fix", "Why first"]}
            rows={[
              ["1", "Login blank screen (B1)", "Hits every user every day"],
              ["2", "History from/to server-side (M4)", "Reports lie as data grows"],
              ["3", "Staff activate + rename Edit (M1/M2)", "Admin trust in Staff screen"],
              ["4", "Hide forbidden staff actions (M3)", "Stops confusing 403 toasts"],
              ["5", "Shared token refresh (M6)", "Stops random logouts after 15m"],
              ["6", "Search debounce (M5)", "Polish; quick win"],
            ]}
          />

          <Callout tone="info" title="Seed password note">
            Seed logins use <Code>test123</Code>, which does not meet the new
            admin password policy (letter + number + special). Creating/changing
            staff passwords in-app correctly requires something like{" "}
            <Code>Passw0rd!</Code>. That mismatch is easy to confuse during QA —
            not a login bug for the seed accounts themselves.
          </Callout>
        </Stack>
      )}

      {view === "working" && (
        <Stack gap={12}>
          <H2>What works fine</H2>
          <Text tone="secondary">Short list — keep shipping these as-is for MVP.</Text>
          <Table
            headers={["#", "Working"]}
            rows={WORKING.map((w, i) => [String(i + 1), w])}
            rowTone={WORKING.map(() => "success" as const)}
          />
        </Stack>
      )}

      {view === "broken" && (
        <Stack gap={16}>
          <Row gap={8} align="center" wrap>
            <H2>What is not working</H2>
            <Spacer />
            {(["All", "Blocker", "Major", "Minor"] as const).map((s) => (
              <Pill key={s} active={sev === s} onClick={() => setSev(s)} size="sm">
                {s}
              </Pill>
            ))}
          </Row>
          <Text tone="secondary">
            Detailed findings with file location and a practical fix tip. Filter by
            severity.
          </Text>

          <Table
            headers={["ID", "Severity", "Roles", "Issue", "Confidence"]}
            columnAlign={["left", "left", "left", "left", "left"]}
            rows={filtered.map((i) => [i.id, i.severity, i.roles, i.title, i.confidence])}
            rowTone={filtered.map((i) => rowTone(i.severity))}
          />

          <Divider />

          {filtered.map((i) => (
            <Card key={i.id} collapsible defaultOpen={i.severity !== "Minor"}>
              <CardHeader
                trailing={
                  <Text size="small" tone="secondary">
                    {i.severity} · {i.roles}
                  </Text>
                }
              >
                {i.id} — {i.title}
              </CardHeader>
              <CardBody>
                <Stack gap={10}>
                  <Callout tone={severityTone(i.severity)} title="What the user sees">
                    {i.what}
                  </Callout>
                  <Stack gap={4}>
                    <Text weight="semibold">Location</Text>
                    <Text>
                      <Code>{i.where}</Code>
                    </Text>
                  </Stack>
                  <Stack gap={4}>
                    <Text weight="semibold">Tip to fix</Text>
                    <Text>{i.tip}</Text>
                  </Stack>
                  <Text size="small" tone="tertiary">
                    {i.confidence}
                  </Text>
                </Stack>
              </CardBody>
            </Card>
          ))}
        </Stack>
      )}

      {view === "by-role" && (
        <Stack gap={16}>
          <H2>By role — user journey</H2>

          <H3>superadmin</H3>
          <Text>
            Login → Home stats → drawer Staff / Categories / Units / Reports →
            Products FAB add → add/adjust stock → withdraw → history → export PDF/Excel
            → Settings logout.
          </Text>
          <Text tone="secondary">
            Broken for this role: B1 login flash; M1–M2 staff UX; M4–M7 shared;
            N1–N3, N5–N7.
          </Text>

          <H3>shopadmin</H3>
          <Text>
            Same admin journey as superadmin (V1 design). Extra pain: M3 offers
            deactivate/password on the superadmin row then fails with 403.
          </Text>

          <H3>employee</H3>
          <Text>
            Login → Home with Withdraw CTA → withdraw stock → view products
            (read-only) → history → settings. No staff/catalog admin/export.
          </Text>
          <Text tone="secondary">
            Broken for this role: B1, M4–M6, N3–N6, N8. Admin-only issues do not
            apply.
          </Text>

          <Divider />

          <H2>Suggested manual retest script</H2>
          <Table
            headers={["Step", "Do this", "Expect"]}
            rows={[
              ["1", "Login as each seed user (EN)", "No blank flash; land on Home"],
              ["2", "Admin: create product + add/adjust/withdraw", "Qty + history update"],
              ["3", "Employee: withdraw only", "Cannot open Staff/Reports"],
              ["4", "Admin: deactivate staff, try activate", "Should restore (today: missing)"],
              ["5", "History: From date older than ~last 100 txs", "Should still find rows"],
              ["6", "Admin: Export PDF + Excel", "File opens / saves"],
              ["7", "Type in product search", "No full-list skeleton flash"],
            ]}
          />

          <Callout tone="neutral" title="Out of scope (not bugs for MVP)">
            Dark theme (commented out), Google sign-in, public signup, multi-shop
            Super Admin UI, POS, offline sync, push notifications.
          </Callout>
        </Stack>
      )}

      <Divider />
      <Text size="small" tone="tertiary">
        Source: live API E2E on http://127.0.0.1:3000/api/v1 + Flutter review under
        mobile/lib/features/* · Seed users from docs/SEED_CREDENTIALS.md · English
        only
      </Text>
    </Stack>
  );
}
