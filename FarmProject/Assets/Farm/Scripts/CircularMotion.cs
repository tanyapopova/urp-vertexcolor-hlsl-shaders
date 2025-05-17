using UnityEngine;

public class CircularMotion : MonoBehaviour
{
    [SerializeField] private Transform center;
    [SerializeField] private float radius = 2f;
    [SerializeField] private float speed = 1f;
    [SerializeField] private float startAngle = 0f; // Смещение начальной фазы в градусах

    private float angle;

    void Start()
    {
        // Переводим градусы в радианы
        angle = startAngle * Mathf.Deg2Rad;
    }

    void Update()
    {
        angle += speed * Time.deltaTime;

        float x = Mathf.Cos(angle) * radius;
        float z = Mathf.Sin(angle) * radius;

        transform.position = center.position + new Vector3(x, 0, z);

        Vector3 direction = new Vector3(-Mathf.Sin(angle), 0, Mathf.Cos(angle));
        if (direction != Vector3.zero)
            transform.rotation = Quaternion.LookRotation(direction);
    }
}