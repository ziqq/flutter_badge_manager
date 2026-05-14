# Platform Interface Deployment

## When to release

Release the platform interface only when the shared contract changes or when its
documentation and package metadata need a publish-relevant update.

## Validation

```sh
cd flutter_badge_manager_platform_interface && make all
```

## Dependency rule

If the platform interface version changes, publish it before the endorsed
implementation packages that depend on it.
