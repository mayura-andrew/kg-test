// ═══════════════════════════════════════════════════════════════════════════════
// Unpack Knowledge Graph — 03_concepts.cypher
// ───────────────────────────────────────────────────────────────────────────────
// PURPOSE : Load all 39 Concept nodes (the A-Box instances).
//           Run AFTER 01_schema.cypher and 02_ontology.cypher.
//
// COVERAGE: Curriculum layers 0–4
//   Layer 0 — pre-calculus foundations (arithmetic → trig → unit circle)
//   Layer 1 — single-variable differentiation
//   Layer 2 — single-variable integration
//   Layer 3 — sequences, series, parametric, polar
//   Layer 4 — multivariable calculus
// ═══════════════════════════════════════════════════════════════════════════════


// ── LAYER 0: Pre-calculus foundations ─────────────────────────────────────────

MERGE (c:Concept {id: "arithmetic"})
SET c.name = "Arithmetic",
    c.description = "Basic number operations: addition, subtraction, multiplication, division.",
    c.core_theory = "The four fundamental operations on numbers. Addition and subtraction are inverse operations. Multiplication is repeated addition. Division is the inverse of multiplication. Forms the numerical foundation for all mathematics.",
    c.type = "Foundation", c.color = "#7A7060", c.curriculum_layer = 0;

MERGE (c:Concept {id: "algebra"})
SET c.name = "Algebra",
    c.description = "Symbolic expression manipulation and equation solving.",
    c.core_theory = "The study of mathematical symbols and rules for manipulating those symbols. Variables represent unknown or general quantities. Equations assert equality between two expressions; solving means finding the variable values that satisfy the equation.",
    c.type = "Foundation", c.color = "#7A7060", c.curriculum_layer = 0;

MERGE (c:Concept {id: "coordinate_geometry"})
SET c.name = "Coordinate Geometry",
    c.description = "Points, lines, and curves on the x-y plane.",
    c.core_theory = "A system using pairs of numbers (coordinates) to uniquely determine positions in a plane. Every point is (x, y). Distance between two points: d = √((x₂-x₁)² + (y₂-y₁)²). Slope of a line: m = (y₂-y₁)/(x₂-x₁). Bridges algebra and geometry.",
    c.type = "Foundation", c.color = "#7A7060", c.curriculum_layer = 0;

MERGE (c:Concept {id: "pythagorean_theorem"})
SET c.name = "Pythagorean Theorem",
    c.description = "Right triangle side relationship: a² + b² = c².",
    c.core_theory = "In any right-angled triangle, the square of the hypotenuse (longest side, opposite the right angle) equals the sum of the squares of the other two sides: a² + b² = c². Critical for related rates problems involving geometric constraints.",
    c.type = "Geometry", c.color = "#1A7A50", c.curriculum_layer = 0;

MERGE (c:Concept {id: "similar_triangles"})
SET c.name = "Similar Triangles",
    c.description = "Equal-angle triangles with proportional sides.",
    c.core_theory = "Two triangles are similar when their corresponding angles are equal. Their corresponding side lengths are proportional, giving a constant ratio r/h = R/H. Used in related rates problems to relate changing lengths through geometric similarity.",
    c.type = "Geometry", c.color = "#1A7A50", c.curriculum_layer = 0;

MERGE (c:Concept {id: "trigonometry_basics"})
SET c.name = "Trigonometry Basics",
    c.description = "Right triangle ratios: sin, cos, tan.",
    c.core_theory = "The study of relationships between angles and side lengths of right triangles. sin θ = opposite/hypotenuse, cos θ = adjacent/hypotenuse, tan θ = opposite/adjacent (SOH-CAH-TOA). These ratios are the foundation for all trigonometric functions.",
    c.type = "Foundation", c.color = "#7A7060", c.curriculum_layer = 0;

MERGE (c:Concept {id: "unit_circle"})
SET c.name = "Unit Circle",
    c.description = "Circle of radius 1 used to define trig functions for all angles.",
    c.core_theory = "A circle of radius 1 centred at the origin. For any angle θ (in radians), the point on the unit circle is (cos θ, sin θ). This extends trig definitions beyond acute angles. The Pythagorean identity cos²θ + sin²θ = 1 follows directly from the unit circle equation x² + y² = 1.",
    c.type = "Foundation", c.color = "#7A7060", c.curriculum_layer = 0;


// ── LAYER 1: Differentiation ───────────────────────────────────────────────────

MERGE (c:Concept {id: "func_basics"})
SET c.name = "Functions",
    c.description = "Mapping inputs to exactly one output.",
    c.core_theory = "A function f: A → B assigns to each element of domain A exactly one element of codomain B. Written f(x) where x is the input. Key properties: domain (valid inputs), codomain (possible outputs), range (actual outputs). Function composition: (f∘g)(x) = f(g(x)).",
    c.type = "Foundation", c.color = "#7A7060", c.curriculum_layer = 1;

MERGE (c:Concept {id: "limits"})
SET c.name = "Limits",
    c.description = "The value a function approaches as input approaches a point.",
    c.core_theory = "lim(x→a) f(x) = L means f(x) gets arbitrarily close to L as x gets arbitrarily close to a (without necessarily equalling a). Foundational for defining both derivatives and integrals. Key rules: sum, product, quotient, and composition of limits.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 1;

MERGE (c:Concept {id: "continuity"})
SET c.name = "Continuity",
    c.description = "A function with no breaks, jumps, or holes.",
    c.core_theory = "f is continuous at x = a if: (1) f(a) is defined, (2) lim(x→a) f(x) exists, and (3) lim(x→a) f(x) = f(a). Informally: the graph can be drawn without lifting the pencil. The Intermediate Value Theorem and Extreme Value Theorem require continuity.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 1;

MERGE (c:Concept {id: "derivatives"})
SET c.name = "Derivatives",
    c.description = "Instantaneous rate of change; slope of the tangent line.",
    c.core_theory = "The derivative f'(x) = lim(h→0)[f(x+h)-f(x)]/h measures the instantaneous rate of change of f at x. Geometrically it is the slope of the tangent line to the graph at that point. Leibniz notation: dy/dx. The derivative is itself a function of x.",
    c.type = "Rate of Change", c.color = "#9B3ABB", c.curriculum_layer = 1;

MERGE (c:Concept {id: "power_rule"})
SET c.name = "Power Rule",
    c.description = "d/dx[xⁿ] = n·xⁿ⁻¹ for any real n.",
    c.core_theory = "The power rule states: d/dx[xⁿ] = n·xⁿ⁻¹ for any real number n. Works for negative and fractional exponents: d/dx[x⁻²] = -2x⁻³, d/dx[√x] = (1/2)x^(-1/2). The most frequently applied differentiation rule.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 1;

MERGE (c:Concept {id: "product_rule"})
SET c.name = "Product Rule",
    c.description = "Derivative of a product: (f·g)' = f'·g + f·g'.",
    c.core_theory = "When two differentiable functions are multiplied, the derivative of their product is: (f·g)' = f'·g + f·g'. Mnemonic: 'derivative of first times second, plus first times derivative of second.' Extends to three or more functions via iteration.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 1;

MERGE (c:Concept {id: "quotient_rule"})
SET c.name = "Quotient Rule",
    c.description = "Derivative of a quotient: (f/g)' = (f'g - fg')/g².",
    c.core_theory = "For differentiable functions with g(x) ≠ 0: d/dx[f/g] = (f'·g - f·g')/g². Mnemonic: 'low d-high minus high d-low, over the square of what's below.' Can be derived from the product rule by writing f/g = f·g⁻¹.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 1;

MERGE (c:Concept {id: "chain_rule"})
SET c.name = "Chain Rule",
    c.description = "Derivative of composite functions: d/dx[f(g(x))] = f'(g(x))·g'(x).",
    c.core_theory = "The chain rule: d/dx[f(g(x))] = f'(g(x))·g'(x). In Leibniz notation: dy/dx = (dy/du)·(du/dx). Interpretation: the rate of change of the outer function evaluated at the inner, multiplied by the rate of change of the inner. Essential for any nested or composite function.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 1;

MERGE (c:Concept {id: "trigonometric_functions"})
SET c.name = "Trigonometric Functions",
    c.description = "Periodic functions sin, cos, tan defined via the unit circle.",
    c.core_theory = "sin(x), cos(x), tan(x) are defined for all real x using the unit circle. Periodic with period 2π for sin and cos. Key identities: sin²x + cos²x = 1; tan x = sin x/cos x. Inverse functions: arcsin, arccos, arctan map back to angles.",
    c.type = "Calculus", c.color = "#1A7A50", c.curriculum_layer = 1;

MERGE (c:Concept {id: "trigonometric_derivatives"})
SET c.name = "Trigonometric Derivatives",
    c.description = "d/dx[sin x] = cos x; d/dx[cos x] = -sin x.",
    c.core_theory = "The fundamental trig derivatives are d/dx[sin x] = cos x and d/dx[cos x] = -sin x. All others follow: d/dx[tan x] = sec²x, d/dx[sec x] = sec x·tan x, d/dx[csc x] = -csc x·cot x, d/dx[cot x] = -csc²x. Derived from the limit definition and sum formulas.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 1;

MERGE (c:Concept {id: "exponential_functions"})
SET c.name = "Exponential Functions",
    c.description = "Functions of the form eˣ or aˣ.",
    c.core_theory = "f(x) = aˣ where a > 0, a ≠ 1. The natural exponential f(x) = eˣ is its own derivative: d/dx[eˣ] = eˣ. For general base: d/dx[aˣ] = aˣ·ln a. Exponential functions model growth and decay. The number e ≈ 2.71828 arises as the base for which the derivative equals the function.",
    c.type = "Calculus", c.color = "#1A7A50", c.curriculum_layer = 1;

MERGE (c:Concept {id: "logarithmic_functions"})
SET c.name = "Logarithmic Functions",
    c.description = "Inverse of exponential functions: ln(x) = log_e(x).",
    c.core_theory = "The natural logarithm ln(x) is the inverse of eˣ: ln(eˣ) = x. Key properties: ln(ab) = ln a + ln b; ln(aⁿ) = n·ln a. Derivative: d/dx[ln x] = 1/x. For general base: d/dx[log_a x] = 1/(x·ln a). Used for logarithmic differentiation of complex products.",
    c.type = "Calculus", c.color = "#1A7A50", c.curriculum_layer = 1;

MERGE (c:Concept {id: "implicit_differentiation"})
SET c.name = "Implicit Differentiation",
    c.description = "Finding dy/dx when y is defined implicitly by an equation.",
    c.core_theory = "When y cannot be isolated explicitly (e.g. x² + y² = 25), differentiate both sides with respect to x, applying the chain rule to every y term: d/dx[y²] = 2y·(dy/dx). Solve algebraically for dy/dx. Essential for related rates problems where the geometric relationship is given implicitly.",
    c.type = "Calculus", c.color = "#6B1A8A", c.curriculum_layer = 1;

MERGE (c:Concept {id: "related_rates"})
SET c.name = "Related Rates",
    c.description = "Finding an unknown rate when related quantities change with time.",
    c.core_theory = "Problems where two or more quantities change over time and are linked by a geometric or physical equation. Strategy: (1) identify the geometric relation, (2) differentiate both sides implicitly with respect to t, (3) substitute known rates and values, (4) solve for the unknown rate. The chain rule applied to time.",
    c.type = "Goal", c.color = "#B85010", c.curriculum_layer = 1;

MERGE (c:Concept {id: "critical_points"})
SET c.name = "Critical Points",
    c.description = "Points where f'(c) = 0 or f'(c) is undefined.",
    c.core_theory = "x = c is a critical point of f if f'(c) = 0 or f'(c) does not exist. Critical points are the only candidates for local maxima and minima (Fermat's Theorem). Finding critical points is step 1 of any optimisation or curve sketching problem.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 1;

MERGE (c:Concept {id: "second_derivative_test"})
SET c.name = "Second Derivative Test",
    c.description = "Classifying critical points using f''(c).",
    c.core_theory = "If f'(c) = 0: f''(c) > 0 → local minimum (concave up); f''(c) < 0 → local maximum (concave down); f''(c) = 0 → inconclusive (use first derivative test). Also determines concavity: f'' > 0 means concave up, f'' < 0 means concave down. Inflection points occur where f'' changes sign.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 1;

MERGE (c:Concept {id: "optimization"})
SET c.name = "Optimization",
    c.description = "Finding maximum or minimum values of a function.",
    c.core_theory = "To optimise f(x) on an interval: (1) find all critical points by solving f'(x) = 0, (2) evaluate f at critical points and endpoints, (3) classify using second derivative test. For applied problems: (1) express the objective quantity as a function of one variable using constraint equations, then apply steps 1–3.",
    c.type = "Goal", c.color = "#B85010", c.curriculum_layer = 1;

MERGE (c:Concept {id: "curve_sketching"})
SET c.name = "Curve Sketching",
    c.description = "Graphing functions using calculus techniques.",
    c.core_theory = "Systematic analysis of f using: domain and range, intercepts (f = 0), asymptotes (lim at boundaries), intervals of increase/decrease (sign of f'), local extrema (critical points), concavity (sign of f''), inflection points (f'' = 0 and sign change). Synthesises all differentiation concepts.",
    c.type = "Goal", c.color = "#B85010", c.curriculum_layer = 1;


// ── LAYER 2: Integration ───────────────────────────────────────────────────────

MERGE (c:Concept {id: "integration"})
SET c.name = "Integration",
    c.description = "Finding antiderivatives and area under curves.",
    c.core_theory = "Integration is the reverse of differentiation. The antiderivative F of f satisfies F'(x) = f(x). The definite integral ∫[a,b]f(x)dx is a number giving the net signed area under f from x=a to x=b. The indefinite integral ∫f(x)dx = F(x) + C represents a family of antiderivatives.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 2;

MERGE (c:Concept {id: "indefinite_integrals"})
SET c.name = "Indefinite Integrals",
    c.description = "Antiderivatives without bounds: ∫f(x)dx = F(x) + C.",
    c.core_theory = "An indefinite integral ∫f(x)dx = F(x) + C where F'(x) = f(x) and C is the constant of integration. Every continuous function has an antiderivative. Common forms: ∫xⁿdx = xⁿ⁺¹/(n+1)+C (n≠-1), ∫eˣdx = eˣ+C, ∫(1/x)dx = ln|x|+C.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 2;

MERGE (c:Concept {id: "definite_integrals"})
SET c.name = "Definite Integrals",
    c.description = "Integration over [a,b] producing a numerical value.",
    c.core_theory = "The definite integral ∫[a,b]f(x)dx = lim(n→∞) Σf(xᵢ*)Δx (Riemann sum). Evaluated via the FTC: ∫[a,b]f(x)dx = F(b) - F(a). Properties: linearity, additivity of intervals, reversal of limits changes sign.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 2;

MERGE (c:Concept {id: "substitution"})
SET c.name = "U-Substitution",
    c.description = "Integration technique using variable substitution.",
    c.core_theory = "Let u = g(x), then du = g'(x)dx, transforming ∫f(g(x))g'(x)dx into ∫f(u)du. This is the chain rule in reverse. Works when the integrand contains a composite function and its derivative. For definite integrals, also transform the limits of integration.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 2;

MERGE (c:Concept {id: "integration_by_parts"})
SET c.name = "Integration by Parts",
    c.description = "∫u dv = uv - ∫v du — product rule in reverse.",
    c.core_theory = "Derived from the product rule: ∫u dv = uv - ∫v du. Choose u and dv using LIATE order (Logarithmic, Inverse trig, Algebraic, Trig, Exponential) — u is the first type present. Used for integrals of products like ∫x·eˣdx, ∫x·sin(x)dx, ∫ln(x)dx.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 2;

MERGE (c:Concept {id: "fundamental_theorem"})
SET c.name = "Fundamental Theorem of Calculus",
    c.description = "The connection between differentiation and integration.",
    c.core_theory = "FTC Part 1: d/dx[∫[a,x]f(t)dt] = f(x) — differentiation undoes integration. FTC Part 2: ∫[a,b]f(x)dx = F(b) - F(a) where F is any antiderivative of f — provides a practical evaluation method. Unifies the two central operations of calculus.",
    c.type = "Equation Type", c.color = "#6B1A8A", c.curriculum_layer = 2;

MERGE (c:Concept {id: "area_between_curves"})
SET c.name = "Area Between Curves",
    c.description = "Area between f(x) and g(x) using definite integration.",
    c.core_theory = "Area = ∫[a,b]|f(x)-g(x)|dx. Procedure: (1) find intersection points by solving f(x) = g(x), (2) determine which function is on top in each sub-interval, (3) integrate the difference. For horizontal slices, integrate with respect to y using inverse functions.",
    c.type = "Goal", c.color = "#B85010", c.curriculum_layer = 2;

MERGE (c:Concept {id: "volume_revolution"})
SET c.name = "Volume of Revolution",
    c.description = "Volume of solids formed by rotating curves.",
    c.core_theory = "Disk method (rotation about x-axis): V = π∫[a,b][f(x)]²dx. Washer method (hollow solid): V = π∫[a,b]([f(x)]²-[g(x)]²)dx. Shell method (rotation about y-axis): V = 2π∫[a,b]x·f(x)dx. Choose method based on the axis of rotation and which variable is simpler.",
    c.type = "Goal", c.color = "#B85010", c.curriculum_layer = 2;


// ── LAYER 3: Series and advanced single-variable ───────────────────────────────

MERGE (c:Concept {id: "sequences_series"})
SET c.name = "Sequences and Series",
    c.description = "Ordered number lists and their infinite sums.",
    c.core_theory = "A sequence {aₙ} is an ordered list of numbers. A series Σaₙ is the sum of sequence terms. Convergence: the series converges if the partial sums Sₙ = a₁+…+aₙ approach a finite limit L as n→∞. Geometric series Σarⁿ converges to a/(1-r) when |r| < 1.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 3;

MERGE (c:Concept {id: "convergence_tests"})
SET c.name = "Convergence Tests",
    c.description = "Methods to determine if infinite series converge.",
    c.core_theory = "Key tests: (1) Divergence Test: if lim aₙ ≠ 0 then Σaₙ diverges. (2) Ratio Test: L = lim|aₙ₊₁/aₙ|; L<1 converges, L>1 diverges. (3) Root Test: L = lim|aₙ|^(1/n). (4) Integral Test. (5) Comparison Test. (6) Alternating Series Test. Each applies under different conditions.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 3;

MERGE (c:Concept {id: "taylor_series"})
SET c.name = "Taylor Series",
    c.description = "Infinite polynomial representation of a function.",
    c.core_theory = "The Taylor series of f centred at a: Σ[f⁽ⁿ⁾(a)/n!](x-a)ⁿ. At a=0 this is a Maclaurin series. Key examples: eˣ = Σxⁿ/n!, sin x = Σ(-1)ⁿx^(2n+1)/(2n+1)!, cos x = Σ(-1)ⁿx^(2n)/(2n)!. Used to approximate functions and solve ODEs.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 3;


// ── LAYER 4: Multivariable calculus ───────────────────────────────────────────

MERGE (c:Concept {id: "partial_derivatives"})
SET c.name = "Partial Derivatives",
    c.description = "Derivatives of multivariable functions with respect to one variable.",
    c.core_theory = "For f(x,y), the partial derivative ∂f/∂x treats y as a constant and differentiates with respect to x only. Similarly for ∂f/∂y. The gradient vector ∇f = (∂f/∂x, ∂f/∂y) points in the direction of steepest ascent and has magnitude equal to the maximum rate of change.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 4;

MERGE (c:Concept {id: "multiple_integrals"})
SET c.name = "Multiple Integrals",
    c.description = "Integration over 2D and 3D regions.",
    c.core_theory = "Double integrals ∬_R f(x,y)dA integrate over a 2D region R. Evaluated as iterated integrals: ∫[a,b]∫[c,d]f(x,y)dy dx. Triple integrals ∭f(x,y,z)dV over 3D regions. Change of variables via Jacobian. Used for area, volume, mass, and centre of mass calculations.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 4;

MERGE (c:Concept {id: "vector_calculus"})
SET c.name = "Vector Calculus",
    c.description = "Calculus applied to vector fields.",
    c.core_theory = "Extends calculus to vector-valued functions F = (F_x, F_y, F_z). Key operators: gradient ∇f (scalar→vector), divergence ∇·F (vector→scalar, measures source strength), curl ∇×F (vector→vector, measures rotation). Fundamental theorems: Green's, Stokes', Divergence theorem.",
    c.type = "Calculus", c.color = "#2D5FCC", c.curriculum_layer = 4;


// ── LINK ALL CONCEPTS TO CURRICULUM ───────────────────────────────────────────

MATCH (cur:Curriculum {id: "undergrad_calculus"}), (c:Concept)
MERGE (cur)-[:COVERS {layer: c.curriculum_layer}]->(c);
