Read Me under development
-- Pattern Breakdown:

-- (%a+): Captures a sequence of alphabetic characters for the name (e.g., "Natelp").

-- %sdies.*Rank:%s: Matches " dies, honorable kill Rank: " but doesn’t capture it.

-- ([%a]+): Captures a sequence of alphabetic characters for the rank (e.g., "Scout").

-- %s%(([%d%.]+)%sHonor Points%): Captures a numeric value (e.g., "0.92") surrounded by parentheses and followed by " Honor Points".
