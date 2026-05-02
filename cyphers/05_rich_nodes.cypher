// ═══════════════════════════════════════════════════════════════════════════════
// Unpack Knowledge Graph — 05_rich_nodes.cypher
// ───────────────────────────────────────────────────────────────────────────────
// PURPOSE : Attach the four rich media node types to existing Concept nodes:
//   :Formula      → HAS_FORMULA    (UI hover state 1 and 2)
//   :L2Label      → HAS_LABEL      (multilingual agent B1 behaviour)
//   :VideoResource→ HAS_RESOURCE   (support agent hover state 3)
//   :UseCase      → APPLIED_IN     (context agent "why am I learning this?")
//
// WHY SEPARATE NODES (not properties)?
//   Each node type is queried by a different agent with a different filter.
//   The UI agent queries only Formula with display_level=1.
//   The multilingual agent queries only L2Label filtered by language_code.
//   Agent 5 queries only VideoResource filtered by language and difficulty.
//   Separate nodes = targeted queries, zero over-fetching.
//
// Run AFTER 03_concepts.cypher.
// ═══════════════════════════════════════════════════════════════════════════════


// ════════════════════════════════════════════════════════════════════════════════
// SECTION 1 — FORMULAS
// display_level: 1 = hover (low CL), 2 = click (medium CL)
// is_primary: true = first formula shown, false = secondary notation
// ════════════════════════════════════════════════════════════════════════════════

MATCH (c:Concept {id:"arithmetic"})
MERGE (f:Formula {id:"form_arith_1"}) SET f.name="Basic Operations", f.latex="a + b \\quad a - b \\quad a \\times b \\quad a \\div b", f.notation_plain="a+b  a-b  a×b  a÷b", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"algebra"})
MERGE (f:Formula {id:"form_alg_1"}) SET f.name="Linear Equation", f.latex="ax + b = c \\Rightarrow x = \\frac{c-b}{a}", f.notation_plain="ax + b = c → x = (c-b)/a", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"algebra"})
MERGE (f:Formula {id:"form_alg_2"}) SET f.name="Quadratic Formula", f.latex="x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}", f.notation_plain="x = (-b ± √(b²-4ac)) / 2a", f.display_level=2, f.is_primary=false
MERGE (c)-[:HAS_FORMULA {primary:false}]->(f);

MATCH (c:Concept {id:"coordinate_geometry"})
MERGE (f:Formula {id:"form_coord_1"}) SET f.name="Distance Formula", f.latex="d = \\sqrt{(x_2-x_1)^2 + (y_2-y_1)^2}", f.notation_plain="d = √((x₂-x₁)² + (y₂-y₁)²)", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"pythagorean_theorem"})
MERGE (f:Formula {id:"form_pyth_1"}) SET f.name="Pythagorean Theorem", f.latex="a^2 + b^2 = c^2", f.notation_plain="a² + b² = c²", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"similar_triangles"})
MERGE (f:Formula {id:"form_sim_1"}) SET f.name="Side Ratio", f.latex="\\frac{r}{h} = \\frac{R}{H}", f.notation_plain="r/h = R/H", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"trigonometry_basics"})
MERGE (f:Formula {id:"form_trig_1"}) SET f.name="SOH-CAH-TOA", f.latex="\\sin\\theta = \\frac{\\text{opp}}{\\text{hyp}} \\quad \\cos\\theta = \\frac{\\text{adj}}{\\text{hyp}} \\quad \\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}", f.notation_plain="sin θ = opp/hyp  cos θ = adj/hyp  tan θ = opp/adj", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"unit_circle"})
MERGE (f:Formula {id:"form_unit_1"}) SET f.name="Pythagorean Identity", f.latex="\\cos^2\\theta + \\sin^2\\theta = 1", f.notation_plain="cos²θ + sin²θ = 1", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"func_basics"})
MERGE (f:Formula {id:"form_func_1"}) SET f.name="Function Notation", f.latex="f: A \\to B \\quad y = f(x)", f.notation_plain="f: A → B  or  y = f(x)", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"limits"})
MERGE (f:Formula {id:"form_lim_1"}) SET f.name="Limit Definition", f.latex="\\lim_{x \\to a} f(x) = L", f.notation_plain="lim(x→a) f(x) = L", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"continuity"})
MERGE (f:Formula {id:"form_cont_1"}) SET f.name="Continuity Condition", f.latex="\\lim_{x \\to a} f(x) = f(a)", f.notation_plain="lim(x→a) f(x) = f(a)", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"derivatives"})
MERGE (f:Formula {id:"form_deriv_1"}) SET f.name="Derivative Definition", f.latex="f'(x) = \\lim_{h \\to 0} \\frac{f(x+h) - f(x)}{h}", f.notation_plain="f'(x) = lim(h→0) [f(x+h)-f(x)]/h", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"power_rule"})
MERGE (f:Formula {id:"form_pow_1"}) SET f.name="Power Rule", f.latex="\\frac{d}{dx}[x^n] = nx^{n-1}", f.notation_plain="d/dx[xⁿ] = n·xⁿ⁻¹", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"product_rule"})
MERGE (f:Formula {id:"form_prod_1"}) SET f.name="Product Rule", f.latex="(fg)' = f'g + fg'", f.notation_plain="(f·g)' = f'·g + f·g'", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"quotient_rule"})
MERGE (f:Formula {id:"form_quot_1"}) SET f.name="Quotient Rule", f.latex="\\left(\\frac{f}{g}\\right)' = \\frac{f'g - fg'}{g^2}", f.notation_plain="(f/g)' = (f'·g - f·g') / g²", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"chain_rule"})
MERGE (f:Formula {id:"form_chain_1"}) SET f.name="Chain Rule", f.latex="\\frac{d}{dx}[f(g(x))] = f'(g(x)) \\cdot g'(x)", f.notation_plain="d/dx[f(g(x))] = f'(g(x))·g'(x)", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"chain_rule"})
MERGE (f:Formula {id:"form_chain_2"}) SET f.name="Leibniz Chain Rule", f.latex="\\frac{dy}{dx} = \\frac{dy}{du} \\cdot \\frac{du}{dx}", f.notation_plain="dy/dx = (dy/du)·(du/dx)", f.display_level=1, f.is_primary=false
MERGE (c)-[:HAS_FORMULA {primary:false}]->(f);

MATCH (c:Concept {id:"trigonometric_functions"})
MERGE (f:Formula {id:"form_tfn_1"}) SET f.name="Tangent Definition", f.latex="\\tan x = \\frac{\\sin x}{\\cos x}", f.notation_plain="tan x = sin x / cos x", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"trigonometric_derivatives"})
MERGE (f:Formula {id:"form_td_1"}) SET f.name="Derivative of Sin", f.latex="\\frac{d}{dx}[\\sin x] = \\cos x", f.notation_plain="d/dx[sin x] = cos x", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"trigonometric_derivatives"})
MERGE (f:Formula {id:"form_td_2"}) SET f.name="Derivative of Cos", f.latex="\\frac{d}{dx}[\\cos x] = -\\sin x", f.notation_plain="d/dx[cos x] = −sin x", f.display_level=1, f.is_primary=false
MERGE (c)-[:HAS_FORMULA {primary:false}]->(f);

MATCH (c:Concept {id:"exponential_functions"})
MERGE (f:Formula {id:"form_exp_1"}) SET f.name="Exponential Derivative", f.latex="\\frac{d}{dx}[e^x] = e^x", f.notation_plain="d/dx[eˣ] = eˣ", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"logarithmic_functions"})
MERGE (f:Formula {id:"form_log_1"}) SET f.name="Natural Log Derivative", f.latex="\\frac{d}{dx}[\\ln x] = \\frac{1}{x}", f.notation_plain="d/dx[ln x] = 1/x", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"implicit_differentiation"})
MERGE (f:Formula {id:"form_impl_1"}) SET f.name="Implicit Diff Example", f.latex="\\frac{d}{dx}[y^2] = 2y\\frac{dy}{dx}", f.notation_plain="d/dx[y²] = 2y·(dy/dx)", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"related_rates"})
MERGE (f:Formula {id:"form_rr_1"}) SET f.name="Ladder Related Rate", f.latex="2x\\frac{dx}{dt} + 2y\\frac{dy}{dt} = 0", f.notation_plain="2x·(dx/dt) + 2y·(dy/dt) = 0", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"critical_points"})
MERGE (f:Formula {id:"form_cp_1"}) SET f.name="Critical Point Condition", f.latex="f'(c) = 0 \\text{ or } f'(c) \\text{ undefined}", f.notation_plain="f'(c) = 0  or  f'(c) undefined", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"second_derivative_test"})
MERGE (f:Formula {id:"form_sdt_1"}) SET f.name="Second Derivative Test", f.latex="f''(c) > 0 \\Rightarrow \\min \\quad f''(c) < 0 \\Rightarrow \\max", f.notation_plain="f''(c)>0 → min;  f''(c)<0 → max", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"optimization"})
MERGE (f:Formula {id:"form_opt_1"}) SET f.name="Optimisation Condition", f.latex="\\frac{df}{dx} = 0 \\Rightarrow \\text{candidate extremum}", f.notation_plain="df/dx = 0 → candidate extremum", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"curve_sketching"})
MERGE (f:Formula {id:"form_cs_1"}) SET f.name="Inflection Point", f.latex="f''(x) = 0 \\text{ and sign of } f'' \\text{ changes}", f.notation_plain="f''(x) = 0 and sign of f'' changes", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"integration"})
MERGE (f:Formula {id:"form_int_1"}) SET f.name="Power Integration", f.latex="\\int x^n dx = \\frac{x^{n+1}}{n+1} + C", f.notation_plain="∫xⁿ dx = xⁿ⁺¹/(n+1) + C", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"indefinite_integrals"})
MERGE (f:Formula {id:"form_indef_1"}) SET f.name="Indefinite Integral", f.latex="\\int f(x)dx = F(x) + C", f.notation_plain="∫f(x)dx = F(x) + C", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"definite_integrals"})
MERGE (f:Formula {id:"form_def_1"}) SET f.name="Definite Integral (FTC)", f.latex="\\int_a^b f(x)dx = F(b) - F(a)", f.notation_plain="∫[a→b] f(x)dx = F(b) − F(a)", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"substitution"})
MERGE (f:Formula {id:"form_sub_1"}) SET f.name="U-Substitution", f.latex="\\int f(g(x))g'(x)dx = \\int f(u)du", f.notation_plain="∫f(g(x))g'(x)dx = ∫f(u)du", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"integration_by_parts"})
MERGE (f:Formula {id:"form_ibp_1"}) SET f.name="Integration by Parts", f.latex="\\int u \\, dv = uv - \\int v \\, du", f.notation_plain="∫u dv = uv − ∫v du", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"fundamental_theorem"})
MERGE (f:Formula {id:"form_ftc_1"}) SET f.name="FTC Part 2", f.latex="\\int_a^b f(x)dx = F(b) - F(a)", f.notation_plain="∫[a→b] f(x)dx = F(b) − F(a)", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"fundamental_theorem"})
MERGE (f:Formula {id:"form_ftc_2"}) SET f.name="FTC Part 1", f.latex="\\frac{d}{dx}\\left[\\int_a^x f(t)dt\\right] = f(x)", f.notation_plain="d/dx[∫ₐˣ f(t)dt] = f(x)", f.display_level=2, f.is_primary=false
MERGE (c)-[:HAS_FORMULA {primary:false}]->(f);

MATCH (c:Concept {id:"area_between_curves"})
MERGE (f:Formula {id:"form_area_1"}) SET f.name="Area Between Curves", f.latex="A = \\int_a^b |f(x) - g(x)| dx", f.notation_plain="A = ∫[a→b] |f(x)−g(x)| dx", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"volume_revolution"})
MERGE (f:Formula {id:"form_vol_1"}) SET f.name="Disk Method", f.latex="V = \\pi \\int_a^b [f(x)]^2 dx", f.notation_plain="V = π·∫[a→b] [f(x)]² dx", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"sequences_series"})
MERGE (f:Formula {id:"form_seq_1"}) SET f.name="Geometric Series", f.latex="S = \\frac{a}{1-r} \\text{ for } |r| < 1", f.notation_plain="S = a/(1−r) for |r|<1", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"convergence_tests"})
MERGE (f:Formula {id:"form_conv_1"}) SET f.name="Ratio Test", f.latex="L = \\lim_{n\\to\\infty}\\left|\\frac{a_{n+1}}{a_n}\\right| \\quad L < 1 \\Rightarrow \\text{converges}", f.notation_plain="L = lim|aₙ₊₁/aₙ|  L<1 → converges", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"taylor_series"})
MERGE (f:Formula {id:"form_taylor_1"}) SET f.name="Taylor Series", f.latex="f(x) = \\sum_{n=0}^{\\infty} \\frac{f^{(n)}(a)}{n!}(x-a)^n", f.notation_plain="f(x) = Σ[f⁽ⁿ⁾(a)/n!]·(x−a)ⁿ", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"partial_derivatives"})
MERGE (f:Formula {id:"form_part_1"}) SET f.name="Partial Derivative", f.latex="\\frac{\\partial f}{\\partial x}\\bigg|_y", f.notation_plain="∂f/∂x (treat y as constant)", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"multiple_integrals"})
MERGE (f:Formula {id:"form_mult_1"}) SET f.name="Double Integral", f.latex="\\iint_R f(x,y)\\,dA", f.notation_plain="∬_R f(x,y)dA", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);

MATCH (c:Concept {id:"vector_calculus"})
MERGE (f:Formula {id:"form_vec_1"}) SET f.name="Divergence", f.latex="\\nabla \\cdot \\mathbf{F} = \\frac{\\partial F_x}{\\partial x} + \\frac{\\partial F_y}{\\partial y} + \\frac{\\partial F_z}{\\partial z}", f.notation_plain="∇·F = ∂Fx/∂x + ∂Fy/∂y + ∂Fz/∂z", f.display_level=1, f.is_primary=true
MERGE (c)-[:HAS_FORMULA {primary:true}]->(f);


// ════════════════════════════════════════════════════════════════════════════════
// SECTION 2 — L2 LABELS (key concepts, 4 languages)
// ════════════════════════════════════════════════════════════════════════════════

// Helper pattern:
// MATCH (c:Concept {id:"<id>"})
// MERGE (l:L2Label {id:"<id>"}) SET l.language_code="<code>", l.label="<label>",
//   l.description_l2="<desc>", l.curriculum_name="<name>", l.text_direction="<ltr|rtl>"
// MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"derivatives"})
MERGE (l:L2Label {id:"l2_deriv_si"}) SET l.language_code="si", l.label="අවකලිතය", l.description_l2="ශ්‍රිතයක ක්ෂණික වෙනස් වීමේ අනුපාතය", l.curriculum_name="අවකලිතය", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"derivatives"})
MERGE (l:L2Label {id:"l2_deriv_ta"}) SET l.language_code="ta", l.label="வகைக்கெழு", l.description_l2="சார்பின் உடனடி மாற்ற வீதம்", l.curriculum_name="வகைக்கெழு", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"derivatives"})
MERGE (l:L2Label {id:"l2_deriv_ar"}) SET l.language_code="ar", l.label="المشتقة", l.description_l2="معدل التغيير اللحظي للدالة", l.curriculum_name="المشتقة", l.text_direction="rtl"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"derivatives"})
MERGE (l:L2Label {id:"l2_deriv_zh"}) SET l.language_code="zh", l.label="导数", l.description_l2="函数的瞬时变化率", l.curriculum_name="导数", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"chain_rule"})
MERGE (l:L2Label {id:"l2_chain_si"}) SET l.language_code="si", l.label="දාම නීතිය", l.description_l2="සංයෝජිත ශ්‍රිතයක අවකලනය", l.curriculum_name="දාම නීතිය", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"chain_rule"})
MERGE (l:L2Label {id:"l2_chain_ta"}) SET l.language_code="ta", l.label="சங்கிலி விதி", l.description_l2="கூட்டு சார்பின் வகைக்கெழு காண நியதி", l.curriculum_name="சங்கிலி விதி", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"chain_rule"})
MERGE (l:L2Label {id:"l2_chain_ar"}) SET l.language_code="ar", l.label="قاعدة السلسلة", l.description_l2="قاعدة إيجاد مشتقة الدالة المركبة", l.curriculum_name="قاعدة السلسلة", l.text_direction="rtl"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"chain_rule"})
MERGE (l:L2Label {id:"l2_chain_zh"}) SET l.language_code="zh", l.label="链式法则", l.description_l2="求复合函数导数的法则", l.curriculum_name="链式法则", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"related_rates"})
MERGE (l:L2Label {id:"l2_rr_si"}) SET l.language_code="si", l.label="සම්බන්ධිත අනුපාත", l.description_l2="කාලය සාපේක්ෂව සම්බන්ධිත රාශිවල අනුපාත", l.curriculum_name="සම්බන්ධිත අනුපාත", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"related_rates"})
MERGE (l:L2Label {id:"l2_rr_ta"}) SET l.language_code="ta", l.label="தொடர்புடைய வீதங்கள்", l.description_l2="காலத்துடன் தொடர்புடைய அளவுகளின் வீத கணக்குகள்", l.curriculum_name="தொடர்புடைய வீதங்கள்", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"related_rates"})
MERGE (l:L2Label {id:"l2_rr_ar"}) SET l.language_code="ar", l.label="المعدلات المترابطة", l.description_l2="مسائل معدلات تغيير الكميات المترابطة بالنسبة للزمن", l.curriculum_name="المعدلات المترابطة", l.text_direction="rtl"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"related_rates"})
MERGE (l:L2Label {id:"l2_rr_zh"}) SET l.language_code="zh", l.label="相关变化率", l.description_l2="与时间相关的变化率问题", l.curriculum_name="相关变化率", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"optimization"})
MERGE (l:L2Label {id:"l2_opt_si"}) SET l.language_code="si", l.label="ප්‍රශස්ත කිරීම", l.description_l2="ශ්‍රිතවල උපරිම හා අවම සෙවීම", l.curriculum_name="ප්‍රශස්ත කිරීම", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"optimization"})
MERGE (l:L2Label {id:"l2_opt_ta"}) SET l.language_code="ta", l.label="உகப்பாக்கல்", l.description_l2="சார்புகளின் உச்ச மற்றும் குறைந்தபட்ச மதிப்புகளைக் காணுதல்", l.curriculum_name="உகப்பாக்கல்", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"optimization"})
MERGE (l:L2Label {id:"l2_opt_ar"}) SET l.language_code="ar", l.label="التحسين", l.description_l2="إيجاد القيم القصوى والصغرى للدوال", l.curriculum_name="التحسين", l.text_direction="rtl"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"optimization"})
MERGE (l:L2Label {id:"l2_opt_zh"}) SET l.language_code="zh", l.label="最优化", l.description_l2="求函数的最大值和最小值", l.curriculum_name="最优化", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"integration"})
MERGE (l:L2Label {id:"l2_int_si"}) SET l.language_code="si", l.label="අනුකලිතය", l.description_l2="ශ්‍රිතයේ ප්‍රතිඅවකලිතය හා වක්‍රය යටතේ වර්ගඵලය", l.curriculum_name="අනුකලිතය", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"integration"})
MERGE (l:L2Label {id:"l2_int_ta"}) SET l.language_code="ta", l.label="தொகையீடு", l.description_l2="சார்பின் வலிச்சொர் மற்றும் வளைகோட்டின் கீழ் பரப்பு", l.curriculum_name="தொகையீடு", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"integration"})
MERGE (l:L2Label {id:"l2_int_ar"}) SET l.language_code="ar", l.label="التكامل", l.description_l2="المشتق العكسي والمساحة تحت المنحنى", l.curriculum_name="التكامل", l.text_direction="rtl"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"integration"})
MERGE (l:L2Label {id:"l2_int_zh"}) SET l.language_code="zh", l.label="积分", l.description_l2="反导数与曲线下面积", l.curriculum_name="积分", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"limits"})
MERGE (l:L2Label {id:"l2_lim_si"}) SET l.language_code="si", l.label="සීමාව", l.description_l2="ශ්‍රිතයක් ළඟා වන අගය", l.curriculum_name="සීමාව", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"limits"})
MERGE (l:L2Label {id:"l2_lim_ta"}) SET l.language_code="ta", l.label="எல்லை", l.description_l2="ஒரு சார்பு நெருங்கும் மதிப்பு", l.curriculum_name="எல்லை", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"limits"})
MERGE (l:L2Label {id:"l2_lim_ar"}) SET l.language_code="ar", l.label="النهاية", l.description_l2="القيمة التي تقترب منها الدالة", l.curriculum_name="النهاية", l.text_direction="rtl"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"limits"})
MERGE (l:L2Label {id:"l2_lim_zh"}) SET l.language_code="zh", l.label="极限", l.description_l2="函数趋近的值", l.curriculum_name="极限", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"fundamental_theorem"})
MERGE (l:L2Label {id:"l2_ftc_si"}) SET l.language_code="si", l.label="කලනයේ මූලික ප්‍රමේය", l.description_l2="අවකලනය හා අනුකලනය සම්බන්ධ කරන ප්‍රමේය", l.curriculum_name="කලනයේ මූලික ප්‍රමේය", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"fundamental_theorem"})
MERGE (l:L2Label {id:"l2_ftc_ta"}) SET l.language_code="ta", l.label="நுண்கணிதத்தின் அடிப்படைத் தேற்றம்", l.description_l2="வகையீடும் தொகையீடும் இணைக்கும் தேற்றம்", l.curriculum_name="நுண்கணிதத்தின் அடிப்படைத் தேற்றம்", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"fundamental_theorem"})
MERGE (l:L2Label {id:"l2_ftc_ar"}) SET l.language_code="ar", l.label="النظرية الأساسية في حساب التفاضل والتكامل", l.description_l2="النظرية التي تربط التفاضل بالتكامل", l.curriculum_name="النظرية الأساسية", l.text_direction="rtl"
MERGE (c)-[:HAS_LABEL]->(l);

MATCH (c:Concept {id:"fundamental_theorem"})
MERGE (l:L2Label {id:"l2_ftc_zh"}) SET l.language_code="zh", l.label="微积分基本定理", l.description_l2="联系微分与积分的定理", l.curriculum_name="微积分基本定理", l.text_direction="ltr"
MERGE (c)-[:HAS_LABEL]->(l);


// ════════════════════════════════════════════════════════════════════════════════
// SECTION 3 — VIDEO RESOURCES (key concepts)
// ════════════════════════════════════════════════════════════════════════════════

MATCH (c:Concept {id:"derivatives"})
MERGE (v:VideoResource {id:"vid_deriv_3b1b"}) SET v.platform="YouTube", v.title="Derivative and Slope of a Curve", v.url="https://www.youtube.com/watch?v=9vKqVkMQHKk", v.language="en", v.duration_sec=780, v.difficulty="beginner", v.channel="3Blue1Brown"
MERGE (c)-[:HAS_RESOURCE]->(v);

MATCH (c:Concept {id:"chain_rule"})
MERGE (v:VideoResource {id:"vid_chain_3b1b"}) SET v.platform="YouTube", v.title="Visualizing the Chain Rule", v.url="https://www.youtube.com/watch?v=YG15m2VwSjA", v.language="en", v.duration_sec=615, v.difficulty="intermediate", v.channel="3Blue1Brown"
MERGE (c)-[:HAS_RESOURCE]->(v);

MATCH (c:Concept {id:"chain_rule"})
MERGE (v:VideoResource {id:"vid_chain_si"}) SET v.platform="YouTube", v.title="Chain Rule — Sinhala", v.url="https://www.youtube.com/watch?v=PLACEHOLDER_CHAIN_SI", v.language="si", v.duration_sec=420, v.difficulty="beginner", v.channel="Sinhala Math Channel"
MERGE (c)-[:HAS_RESOURCE]->(v);

MATCH (c:Concept {id:"related_rates"})
MERGE (v:VideoResource {id:"vid_rr_khan"}) SET v.platform="YouTube", v.title="Related Rates — Ladder Problem", v.url="https://www.youtube.com/watch?v=I9mVUo-bhM8", v.language="en", v.duration_sec=600, v.difficulty="intermediate", v.channel="Khan Academy"
MERGE (c)-[:HAS_RESOURCE]->(v);

MATCH (c:Concept {id:"related_rates"})
MERGE (v:VideoResource {id:"vid_rr_prof"}) SET v.platform="YouTube", v.title="Related Rates Full Guide", v.url="https://www.youtube.com/watch?v=8PKfDz_ePqg", v.language="en", v.duration_sec=920, v.difficulty="intermediate", v.channel="Professor Leonard"
MERGE (c)-[:HAS_RESOURCE]->(v);

MATCH (c:Concept {id:"optimization"})
MERGE (v:VideoResource {id:"vid_opt_khan"}) SET v.platform="YouTube", v.title="Optimization with Calculus", v.url="https://www.youtube.com/watch?v=YDU5MFi3TtI", v.language="en", v.duration_sec=750, v.difficulty="intermediate", v.channel="Khan Academy"
MERGE (c)-[:HAS_RESOURCE]->(v);

MATCH (c:Concept {id:"integration"})
MERGE (v:VideoResource {id:"vid_int_3b1b"}) SET v.platform="YouTube", v.title="Integration and the Fundamental Theorem", v.url="https://www.youtube.com/watch?v=rfG8ce4nNh0", v.language="en", v.duration_sec=860, v.difficulty="beginner", v.channel="3Blue1Brown"
MERGE (c)-[:HAS_RESOURCE]->(v);

MATCH (c:Concept {id:"fundamental_theorem"})
MERGE (v:VideoResource {id:"vid_ftc_3b1b"}) SET v.platform="YouTube", v.title="Fundamental Theorem of Calculus", v.url="https://www.youtube.com/watch?v=FnJqaIESC2s", v.language="en", v.duration_sec=740, v.difficulty="intermediate", v.channel="3Blue1Brown"
MERGE (c)-[:HAS_RESOURCE]->(v);

MATCH (c:Concept {id:"limits"})
MERGE (v:VideoResource {id:"vid_lim_3b1b"}) SET v.platform="YouTube", v.title="Limits and the Definition of Derivatives", v.url="https://www.youtube.com/watch?v=kfF40MiS7zA", v.language="en", v.duration_sec=710, v.difficulty="beginner", v.channel="3Blue1Brown"
MERGE (c)-[:HAS_RESOURCE]->(v);

MATCH (c:Concept {id:"implicit_differentiation"})
MERGE (v:VideoResource {id:"vid_impl_khan"}) SET v.platform="YouTube", v.title="Implicit Differentiation", v.url="https://www.youtube.com/watch?v=aVuMH0SJ7GQ", v.language="en", v.duration_sec=660, v.difficulty="intermediate", v.channel="Khan Academy"
MERGE (c)-[:HAS_RESOURCE]->(v);

MATCH (c:Concept {id:"taylor_series"})
MERGE (v:VideoResource {id:"vid_taylor_3b1b"}) SET v.platform="YouTube", v.title="Taylor Series — 3Blue1Brown", v.url="https://www.youtube.com/watch?v=3d6DsjIBzJ4", v.language="en", v.duration_sec=820, v.difficulty="advanced", v.channel="3Blue1Brown"
MERGE (c)-[:HAS_RESOURCE]->(v);


// ════════════════════════════════════════════════════════════════════════════════
// SECTION 4 — USE CASES (key concepts)
// ════════════════════════════════════════════════════════════════════════════════

MATCH (c:Concept {id:"related_rates"})
MERGE (u:UseCase {id:"uc_rr_ladder"}) SET u.domain="Engineering / Safety", u.description="A ladder sliding from a wall — how fast does the top descend as the base moves outward?", u.problem_example="A 10m ladder leans against a wall. Its base slides away at 1 m/s. How fast is the top descending when the base is 6m from the wall?"
MERGE (c)-[:APPLIED_IN]->(u);

MATCH (c:Concept {id:"related_rates"})
MERGE (u:UseCase {id:"uc_rr_tank"}) SET u.domain="Civil Engineering / Hydraulics", u.description="Water draining from a conical tank — how fast does the water level drop?", u.problem_example="A conical tank (height 4m, radius 2m) drains at 2 m³/min. How fast is the water level falling when h = 3m?"
MERGE (c)-[:APPLIED_IN]->(u);

MATCH (c:Concept {id:"optimization"})
MERGE (u:UseCase {id:"uc_opt_cylinder"}) SET u.domain="Manufacturing / Material Cost", u.description="Designing the most material-efficient cylindrical can for a fixed volume.", u.problem_example="A cylindrical can must hold exactly 355 mL. Find the radius and height that minimise the total surface area."
MERGE (c)-[:APPLIED_IN]->(u);

MATCH (c:Concept {id:"optimization"})
MERGE (u:UseCase {id:"uc_opt_fence"}) SET u.domain="Agriculture / Land Use", u.description="Maximising fenced area with a fixed length of fencing along a barn wall.", u.problem_example="A farmer has 200m of fencing for a rectangular paddock against a barn wall. What dimensions maximise the area?"
MERGE (c)-[:APPLIED_IN]->(u);

MATCH (c:Concept {id:"integration"})
MERGE (u:UseCase {id:"uc_int_physics"}) SET u.domain="Physics / Work Done", u.description="Work done by a variable force equals the integral of force over displacement.", u.problem_example="A spring (k=500 N/m) is compressed 0.2m from rest. Calculate the work done using integration."
MERGE (c)-[:APPLIED_IN]->(u);

MATCH (c:Concept {id:"derivatives"})
MERGE (u:UseCase {id:"uc_deriv_physics"}) SET u.domain="Physics / Velocity and Acceleration", u.description="Velocity is the first derivative and acceleration the second derivative of position.", u.problem_example="A ball has position s(t) = 5t² - 20t + 4. Find its velocity and acceleration at t = 2s."
MERGE (c)-[:APPLIED_IN]->(u);

MATCH (c:Concept {id:"chain_rule"})
MERGE (u:UseCase {id:"uc_chain_physics"}) SET u.domain="Physics / Composite Motion", u.description="Differentiating position when it depends on an intermediate variable.", u.problem_example="Pressure p depends on altitude h which depends on time t. Find dp/dt using the chain rule."
MERGE (c)-[:APPLIED_IN]->(u);

MATCH (c:Concept {id:"fundamental_theorem"})
MERGE (u:UseCase {id:"uc_ftc_physics"}) SET u.domain="Physics / Net Displacement", u.description="Using the FTC to find net displacement from a velocity function over a time interval.", u.problem_example="A particle has v(t) = 3t² - 2t. Find the net displacement from t=0 to t=3 using the FTC."
MERGE (c)-[:APPLIED_IN]->(u);

MATCH (c:Concept {id:"implicit_differentiation"})
MERGE (u:UseCase {id:"uc_impl_circle"}) SET u.domain="Geometry / Tangent Lines", u.description="Finding slope of a tangent to a circle without explicitly solving for y.", u.problem_example="Find the slope of the tangent to x² + y² = 25 at the point (3, 4)."
MERGE (c)-[:APPLIED_IN]->(u);

MATCH (c:Concept {id:"taylor_series"})
MERGE (u:UseCase {id:"uc_taylor_computing"}) SET u.domain="Computer Science / Numerical Methods", u.description="Calculators and software use Taylor series to evaluate sin, cos, ln, and exp.", u.problem_example="How does a CPU compute sin(0.1) without geometric construction? Via Taylor: sin(x) ≈ x - x³/6 + x⁵/120."
MERGE (c)-[:APPLIED_IN]->(u);
