# Mixed Value Types Test Package

This package tests the Runner's ability to handle mixed value types in prop values (Test Case 3).

## Props

- **string_expression**: String prop with expression (e.g., `"Props.environment + '-suffix'"`)
- **policy_config**: Object prop value (e.g., `{"rules": [...], "version": "1.6"}`)
- **array_value**: Array prop value (e.g., `["item1", "item2", "item3"]`)
- **boolean_value**: Boolean prop value (e.g., `true`)
- **number_value**: Number prop value (e.g., `42`)
- **mixed_object**: Object with nested string expressions (e.g., `{"metadata": {"environment": "Props.environment"}}`)

## Testing

Use with the `mixed_value_types_test@1.0.0` blueprint:

```bash
bricks run mixed_value_types_test@1.0.0 --props '{
  "environment": "production",
  "region": "us-east-1"
}'
```

## Expected Behavior

- String expressions should be evaluated (e.g., `Props.environment + "-suffix"` becomes `"production-suffix"`)
- Object values should be passed through directly without expression evaluation
- Array values should be passed through directly
- Boolean values should be passed through directly
- Number values should be passed through directly
- Mixed objects with nested string expressions should have those expressions evaluated recursively
