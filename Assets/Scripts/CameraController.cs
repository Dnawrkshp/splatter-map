using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public float MovementSpeed = 10f;
    public float RotationSpeed = 100f;

    private float _pitch = 0, _yaw = 0;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
    }

    // Update is called once per frame
    void Update()
    {
        float m = Input.GetKey(KeyCode.LeftShift) ? 3f : 1f;
        float v = Input.GetAxis("Vertical") * m;
        float h = Input.GetAxis("Horizontal") * m;

        float x = Input.GetAxis("Mouse X");
        float y = Input.GetAxis("Mouse Y");

        _pitch += -y * RotationSpeed * Time.deltaTime;
        _yaw += x * RotationSpeed * Time.deltaTime;


        this.transform.position += this.transform.forward * v * MovementSpeed * Time.deltaTime;
        this.transform.position += this.transform.right * h * MovementSpeed * Time.deltaTime;

        if (Input.GetKey(KeyCode.E))
            this.transform.position += Vector3.up * m * MovementSpeed * Time.deltaTime;
        if (Input.GetKey(KeyCode.Q))
            this.transform.position -= Vector3.up * m * MovementSpeed * Time.deltaTime;

        this.transform.rotation = Quaternion.AngleAxis(_yaw, Vector3.up);
        this.transform.rotation *= Quaternion.AngleAxis(_pitch, Vector3.right);


        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Cursor.lockState = CursorLockMode.None;
        }
    }
}

