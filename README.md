# MELI Conversion & Retention Analysis
## Project_Overview
This project sought to address critical product challenges by mapping the complete user conversion funnel and performing a comprehensive cohort analysis to evaluate long-term retention. By leveraging advanced SQL techniques—such as Common Table Expressions (CTEs) and window functions—the analysis aimed to pinpoint specific friction points in the user journey, quantify attrition trends, and derive actionable, data-driven recommendations to optimize product performance and enhance user engagement.
## Technologies & Skills:

- SQL, CTEs, A/B Testing, Funnel Analysis, Retention Analysis, Cohort Analysis, Conversion Rate Analysis, User Behavior Analysis.

## Key questions:

- At which stage of the funnel is the user drop-off highest?
- What is the retention rate of our user cohorts over time?

## Methodology

- **Data Preparation & Cleaning:** Conducted data validation to address missing values and ensure consistent event timestamps across the dataset.
- **Funnel Construction:** Utilized **Common Table Expressions (CTEs)** to segment the user journey into distinct conversion stages, enabling precise identification of friction points.
- **Retention Analysis:** Applied **Cohort Analysis** to track user engagement over time, segmenting users by acquisition date to identify behavioral trends.
- **Optimization Modeling:** Modeled the potential impact of hypothetical product improvements on overall conversion rates to support data-driven decision-making.

## **Conclusions and Recommendations**

### Conversion Funnel Analysis (Jan 2025 – Aug 2025)

- **Insight:** The analysis revealed a critical bottleneck between the `select_item` and `add_to_cart` stages, with a significant 65.88% drop-off rate. This trend is consistent across all countries; even in Peru and Uruguay, where initial interest (`select_item`) remains strong (above 80%), attrition spikes at the same point.
- **Recommendation:** Given that 60% of users abandon the process at `add_to_cart`, I recommend a UX audit in collaboration with the Design team. I propose conducting A/B testing on the interface and evaluating external variables—such as pricing strategy—to determine if the friction is technical or perception-based.

### Cohort Retention Analysis (Jan 2025 – Jun 2025)

- **Insight:** Users demonstrate strong short-term engagement, with an 86.78% average retention rate within the first 7 days. However, there is a consistent 30% decline in retention for each subsequent period (14, 21, and 28 days). Brazil and Mexico currently lead in performance, though they share the same churn pattern.
- **Recommendation:** To mitigate the drop-off observed after the first week, I recommend a comprehensive UX audit of the post-onboarding experience. Furthermore, I suggest implementing targeted loyalty and re-engagement campaigns starting at day 14, where the highest churn rates are concentrated.
