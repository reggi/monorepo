# `EventAsPromised`

## Why?

Let's you `await` or call `.then()` on the `.emit()` method, allowing you to execute code after all the `.on()` handlers have finished executing.

## Example

```js
await function fn() {
  let event = new EventAsPromised()

  event.on('customerAdd', (data) => {
    let status = {'added': true}
    return Promise.resolve(status).delay(100)
  })

  let data = await event.emit('customerAdd', {'name': 'Thomas'})

  console.log(data) // => [{'added': true}]  
}
```

`await` and `.then()` are return the same `data` here:

```js
let data = await event.emit('customerAdd', {'name': 'Thomas'})
console.log(data) // => [{'added': true}]  

event.emit('customerAdd', {'name': 'Thomas'})
  .then(data => {
    console.log(data) // => [{'added': true}]  
  })
```
